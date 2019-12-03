//
//  GameManeger.swift
//  Fishing_Demo
//
//  Created by Tasuku Kubo on 2019/11/29.
//  Copyright © 2019 Spike. All rights reserved.
//

import ARKit
import Foundation
import CoreMotion

//timer

class GameStatus{
    //魚の情報
    //ゲーム時間
}

class GameScene {
    init(status:GameStatus){
        self.status=status
    }
    var status : GameStatus
    func tap(){}
    func release(){}
    func update(cameraNode:SCNNode,acc:SCNVector3,rot:SCNVector3){
        fatalError()
    }
}
class Visualizer{
    //平面ノードのち位置
    //平面までの距離を返す関数
    //BaseNode(child:float,plane)
    //anchorの位置にBaseNodeを移動
    //rendererからVisualizerを呼び出す(BaseNode の移動)
    init(){
        let objGeometry = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.diffuse.intensity = 0.8;
        objGeometry.materials = [material]
        floatNode=SCNNode(geometry: objGeometry)
    }
    //Is it required to write the sceneView in here？
    //If not, where the sceneView should be written in?
    
    //This is the function to get camera position and to define the initial position of floatNode
    //This function requires the camera position as Index(World coordinates)
    func moveFloat(to pos:SCNVector3){
        floatNode.position = pos
    }
    //target まで移動(updateを使用)
    func setInitialPos(to campos:SCNVector3){
        floatNode.position = campos
    }
    
    func setFloatVel(_ vel:SCNVector3){
        floatVel = vel
    }
    //It is unimplemented to calculate gravity yet
    //必要な移動が終了した時にV=0
    func update(){
        let newx = floatPos.x + floatVel.x * 0.01
        let newy = floatPos.y + floatVel.y * 0.01
        let newz = floatPos.z + floatVel.z * 0.01
        floatNode.position = SCNVector3(newx,newy,newz)
    }
    var floatPos:SCNVector3{get{return floatNode.position}}
    let floatNode:SCNNode
    var floatVel=SCNVector3(0,0,0)
}

class Casting:GameScene{
    let visual = Visualizer()
    var campos=SCNVector3(0,0,0)
    var vel=SCNVector3(0,0,0)
    //func collision is needed
    //The Visualizer manages the velocity of the float
    //This class has to pass the initial posision and velocity of the float to the visualizer
    @override update(cameraNode: SCNNode, acc: SCNVector3, rot: SCNVector3) {
        vel = acc
        campos = cameraNode.convertPosition(SCNVector3(0,0,0),to:nil)
    }
    
    func collision(){
        // return  the flag which means wheather collide or not
    }
    
    func release(){
        visual.moveFloat(to:campos)
        visual.setFloatVel(vel)
    }
}
class Fight{
}
class Hooking{
}

class GameManeger{
}
