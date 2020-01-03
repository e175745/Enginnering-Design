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

class Visualizer
{
    var scene = SCNScene()
    var overlay: SKScene?
    
    var objects: [MovingObject] = []
    var texts: [String:SKLabelNode] = [:]
    
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
        let dummyFloat = SCNNode(geometry: SCNSphere(radius: 0.01))
        dummyFloat.geometry?.firstMaterial?.diffuse.contents = SCNColor.red
        floatObject = makeObject(with: dummyFloat)
    }
    
    func moveFloat(to: SCNVector3) {
        floatObject!.position = to
        //print(floatObject!.position)
    }
    
    // Fight専用
    func updateVelocity(to position: SCNVector3){
        floatObject!.velocity = (position-floatObject!.position)
        
    }
    
}

