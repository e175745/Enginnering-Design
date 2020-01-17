//
//  SCNView.swift
//  Fishing_Demo
//
//  Created by 松本　カズマ on 2019/12/31.
//  Copyright © 2019 Spike. All rights reserved.
//

import UIKit
import SceneKit

class ModelView: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
       
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: -6, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode() // ノードを作成
        lightNode.light = SCNLight() // ノードに光源を持たせる
        lightNode.light!.type = SCNLight.LightType.omni // 光源をスポットライトタイプにする
        lightNode.position = SCNVector3(x: 0, y: 100, z: 0) // ノードの座標を設定（尚y軸が所謂垂直方向）
        lightNode.rotation = SCNVector4(1, 0, 0, -M_PI / 2.0) // ノードの方向をデフォルトの方向（y軸方向）から、(1, 0, 0)の方向に対し-π/2だけ回転させるようにする
        lightNode.name = "spotLight"
        scene.rootNode.addChildNode(lightNode)
        
        let floatScene = SCNScene(named: "Float.scn", inDirectory: "art.scnassets")
        if let objNode = floatScene?.rootNode.childNode(withName: "Float", recursively: true){
            objNode.scale = SCNVector3(0.01, 0.01, 0.01)
            // Cubeの座標を設定
            objNode.position = SCNVector3(0,0,0)
            scene.rootNode.addChildNode(objNode)
            
            sceneView.scene=scene
            sceneView.backgroundColor = UIColor.black
            sceneView.autoenablesDefaultLighting = true
            sceneView.isUserInteractionEnabled = false
            
            
        }
    }
}
