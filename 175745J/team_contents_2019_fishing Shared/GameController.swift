//
//  GameController.swift
//  team_contents_2019_fishing Shared
//
//  Created by Yuhei Akamine on 2019/12/04.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import SceneKit
import SpriteKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
    typealias View = NSView
#else
    typealias SCNColor = UIColor
    typealias View = UIView
#endif

class GameController: NSObject, SCNSceneRendererDelegate{

    unowned let view: View
    unowned let sceneRenderer: SCNSceneRenderer
    
    var pointOfView : SCNVector3?
    var directionOfView : SCNVector3?
    
    let visualizer : FishingVisualizer // lifeサイクルがこのクラスと同じ．(コンポーネント)
    let status: GameStatus
    var scene: GameScene? //これは集約
    
    var acc=SCNVector3(0,0,0)
    var gyro=SCNVector3(0,0,0)
    var plane=SCNVector3(0,0,0)
    let timerInterval = 0.033
    let testnode=SCNNode()

    init(sceneRenderer renderer: SCNSceneRenderer, view: View) {
        sceneRenderer = renderer
        self.view = view
        visualizer = FishingVisualizer(arScene:sceneRenderer.scene!)
        status = GameStatus()
        
        let skscene = SKScene(size: CGSize(width: view.frame.width, height: view.frame.height))
        skscene.isUserInteractionEnabled = false
        renderer.overlaySKScene = skscene
        visualizer.overlay = skscene
        super.init()
        
        prepareScene()

        
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) {[weak self] _ in
            self?.onTimer()
        }
    }
    
    func plane_pos(pos:SCNVector3){
        self.plane = pos
    }
    
    func setAcc(acc:SCNVector3){
        self.acc = acc
    }
    
    func setGyro(gyro:SCNVector3){
        self.gyro = gyro
    }
    
    func retry() {
        prepareScene()
    }
    
    private func prepareScene() {
        let firstScene = CastingScene(status: status, visualizer: visualizer)
        
        scene = firstScene
        scene!.prepare()
        
        
    }
    
    func onTimer() {
        let center = SCNVector3(view.frame.width/2, view.frame.height/2, 0)
        let optical_axis = SCNVector3(view.frame.width/2, view.frame.height/2, 1)
        
        guard let base = sceneRenderer.scene?.rootNode.childNode(withName: "base", recursively: true) else {return}
        pointOfView = sceneRenderer.unprojectPoint(center)-base.position
        directionOfView = (sceneRenderer.unprojectPoint(optical_axis)-pointOfView!).normalized
        
        visualizer.update(deltaTime: timerInterval)
        visualizer.makeLine(status: self.status)
        
        status.eyePoint = pointOfView!
        status.viewVector = directionOfView!
        
        if let scene = self.scene {
            scene.update(acc:self.acc,gyro:self.gyro)
            visualizer.showText(name: "state", text: scene.name(), at: CGPoint(x:0,y:30))
            
            if let nextScene = scene.nextScene() {
                self.scene = nextScene
            }
        }
        
        //for debug
        #if false
        print(pointOfView, directionOfView)
        var node : SCNNode?
        if visualizer.scene.rootNode.childNode(withName: "direction", recursively: false) == nil {
            node = SCNNode(geometry: SCNSphere(radius: 1))
            visualizer.scene.rootNode.addChildNode(node!)
        }
        node!.position = pointOfView! + directionOfView!*10
        
        #endif
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }

    func touchBegin() {
        scene?.touched()
    }
    
    func touchEnd() {
        scene?.released()
    }
    
}
