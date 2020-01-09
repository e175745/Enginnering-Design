//
//  Visualizer.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import ARKit
import AVFoundation

class MovingObject
{
    let node: SCNNode
    var position: SCNVector3 {
        get { return node.position }
        set(p) { node.position = p }
    }
    var velocity: SCNVector3 = SCNVector3()
    var gravity: SCNVector3 = SCNVector3()
    
    init(node: SCNNode) {
        self.node = node
    }
    
    func accelerate(by acc: SCNVector3) {
        velocity += acc
    }
    
    func update(deltaTime: Double) {
        velocity += gravity * SCNFloat(deltaTime)
        position += velocity * SCNFloat(deltaTime)
    }
}

class Visualizer{
    var scene = SCNScene()
    var overlay: SKScene?
    
    var objects: [MovingObject] = []
    var texts: [String:SKLabelNode] = [:]
    var audioPlayer: AVAudioPlayer!
    
    init() {
        
    }
    init(arScene: SCNScene){
        
    }
    
    func update(deltaTime:Double) {
        for ob in objects {
            ob.update(deltaTime:deltaTime)
        }
    }
    
    func makeObject(with node: SCNNode) -> MovingObject {
        let ob = MovingObject(node:node)
        objects.append(ob)
        //planeNode.addChildNode(node)
        //scene.rootNode.addChildNode(node)
        if let base = scene.rootNode.childNode(withName: "base", recursively: true){
            
            base.addChildNode(node)
            //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            //ship.removeFromParentNode()
        }
        return ob
    }
    
    func showText(name:String, text:String, at:CGPoint) {
        if let overlay = self.overlay {
            var pos = at
            #if os(macOS)
            pos.y = overlay.frame.height - pos.y
            #endif
            
            let node = texts[name]
            if node == nil {
                let n = SKLabelNode()
                n.horizontalAlignmentMode = .left
                n.verticalAlignmentMode = .baseline
                texts[name] = n
                overlay.addChild(n)
            }
            
            node?.text = text
            node?.position = pos
        }
    }
}

class FishingVisualizer : Visualizer
{
    var floatObject: MovingObject?
    let GRAVITY = SCNVector3(0,-0.98,0)
    
    override init(arScene:SCNScene) {
        super.init()
        prepareScene(arScene: arScene)
    }
    
    private func prepareScene(arScene:SCNScene) {
        scene = arScene//SCNScene(named: "Art.scnassets/ship.scn")!
        
        let base = SCNNode()
        base.name="base"
        scene.rootNode.addChildNode(base)
        makeFloatVisual()
    }
    
    private func makeFloatVisual() {
        /*
        let dummyFloat = SCNNode(geometry: SCNSphere(radius: 0.01))
        dummyFloat.geometry?.firstMaterial?.diffuse.contents = SCNColor.red
        */
        let floatScene = SCNScene(named: "Float_2.scn", inDirectory: "Art.scnassets")
        if let dummyFloat = floatScene?.rootNode.childNode(withName: "Float", recursively: true){
            dummyFloat.scale = SCNVector3(0.01, 0.01, 0.01)
            floatObject = makeObject(with: dummyFloat)
        }
    }
    
    func makeLine(status:GameStatus){
        if !status.isHolding{
        if let base=scene.rootNode.childNode(withName: "base", recursively: true){
        if let float=floatObject{
            let from = SCNVector3(status.eyePoint.x+status.viewVector.x*0.1,status.eyePoint.y+status.viewVector.y*0.1+0.4,status.eyePoint.z+status.viewVector.z*0.1)
            let to = float.position
            if let oldLineObject = base.childNode(withName:"line",recursively: true){
                oldLineObject.removeFromParentNode()
                }
            let source = SCNGeometrySource(vertices: [from, to])
            let indices: [Int32] = [0, 1]
            let element = SCNGeometryElement(indices: indices, primitiveType: .line)
            let line = SCNGeometry(sources: [source], elements: [element])
            line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.blinn
            let dummyLine = SCNNode(geometry: line)
            dummyLine.geometry?.firstMaterial?.emission.contents = SCNColor.white
            dummyLine.name="line"
            base.addChildNode(dummyLine)
        }
    }
    }
    }
    
    func moveFloat(to: SCNVector3) {
        floatObject!.position = to
        //print(floatObject!.position)
    }
    
    // Fight専用
    func updateVelocity(to position: SCNVector3){
        floatObject!.velocity = (position-floatObject!.position)
        
    }
    
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }

        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self as? AVAudioPlayerDelegate

            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }
}

