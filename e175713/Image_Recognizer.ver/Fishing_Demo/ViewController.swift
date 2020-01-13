//
//  ViewController.swift
//  Fishing_Demo
//
//  Created by 松本　カズマ on 2019/10/10.
//  Copyright © 2019 Spike. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //AR Resourcesに目的の画像が埋め込まれている
    let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
    
    var existence = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // デバックオプション
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        sceneView.addGestureRecognizer(tapGesture)
        
        // longPress
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressView))
        sceneView.addGestureRecognizer(longPressGesture)
        
        // オムニライトを追加
        let lightNode = SCNNode()
        lightNode .light = SCNLight()
        lightNode .light!.type = .omni
        lightNode .position = SCNVector3(x: 0, y: 10, z: 10)
         scene.rootNode.addChildNode(lightNode )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    func createLineNode(from: SCNVector3, to: SCNVector3) -> SCNNode {
        let source = SCNGeometrySource(vertices: [from, to])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let line = SCNGeometry(sources: [source], elements: [element])
        line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.blinn
        let lineNode = SCNNode(geometry: line)
        lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return lineNode
    }
    
    func updateLineNode(from: SCNVector3, to: SCNVector3){
        if let lineNode = sceneView.scene.rootNode.childNode(withName: "line", recursively: true){
            lineNode.removeFromParentNode()
            let lineNode = createLineNode(from: from, to: to)
                lineNode.name = "line"
            sceneView.scene.rootNode.addChildNode(lineNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let camera = sceneView.pointOfView else {
            return
        }
        if existence{
            if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
                let cameraPos = SCNVector3Make(0, 0, -0.5)
                let position = camera.convertPosition(cameraPos, to: nil)
                objNode.position = position
            }
        }
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
            let cubePosi = objNode.position
            let homePosi = SCNVector3(0,0,-0.5)
            if let lineNode = sceneView.scene.rootNode.childNode(withName: "line", recursively: true){
                lineNode.removeFromParentNode()
                let lineNode = createLineNode(from: homePosi, to: cubePosi)
                    lineNode.name = "line"
                sceneView.scene.rootNode.addChildNode(lineNode)
            }else {print("Line Not Found")}
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor{
            // 平面ジオメトリを作成
            let geometry = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            geometry.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)

            // 平面ジオメトリを持つノードを作成
            let planeNode = SCNNode(geometry: geometry)
                //x-z平面に合わせる
            planeNode.eulerAngles.x = -Float.pi/2
            //planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
            
            DispatchQueue.main.async(execute: {
                // 検出したアンカーに対応するノードに子ノードとして持たせる
                node.addChildNode(planeNode)
            })
        }
        
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
        let cubePosi = objNode.position
            let homePosi = SCNVector3(0,0,-0.5)
        let lineNode = createLineNode(from: homePosi, to: cubePosi)
            lineNode.name = "line"
        sceneView.scene.rootNode.addChildNode(lineNode)
        }
    }
    
    @objc func tapView(sender: UIGestureRecognizer) {
        existence = false
        
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
    
            let location = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingGeometry)
        
            if let result = hitTestResult.first {
                // オブジェクトを飛ばす
                let target = SCNVector3Make(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y + 0.1,
                    result.worldTransform.columns.3.z)
                let action = SCNAction.move(to: target, duration: 1)
                objNode.runAction(action)
            }
        }
    }
    
    @objc func longPressView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: sceneView)
            let hitTest  = sceneView.hitTest(location)
            if let result = hitTest.first  {
                if result.node.name == "obj"
                {
                    result.node.removeFromParentNode();
                }
            }
        }
    }
    
    @IBAction func DeleteKey(_ sender: Any) {
        // sessionを停止
        sceneView.session.pause()
        // 全てのNodeに対して処理を行う
        sceneView.scene.rootNode.enumerateChildNodes {(node, _) in
        // Nodeを削除
        node.removeFromParentNode()
        }
        // sessionを再開
        sceneView.session.run(ARWorldTrackingConfiguration())
    }
    
    
    @IBAction func SettingButton(_ sender: Any) {
        
        if existence{
            if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
                
                let homePosi = SCNVector3(0,0,-0.5)
                let action = SCNAction.move(to: homePosi, duration: 1)
                objNode.runAction(action)
            }
        }else{
        
            // Cubeを作成
            // let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            let obj = SCNSphere(radius: 0.05)
            let objNode = SCNNode(geometry: obj)
            objNode.name = "obj"
            
            
            // Cubeのマテリアルを設定
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            material.diffuse.intensity = 0.8;
            objNode.geometry?.materials = [material]

            /*
            guard let scene = SCNScene(named: "cube.scn", inDirectory: "art.scnassets") else {fatalError()}
            guard let objNode = scene.rootNode.childNode(withName: "obj", recursively: true) else {fatalError()}
            objNode.scale = SCNVector3(0.001, 0.001, 0.001)
            */
            // Cubeの座標を設定
            objNode.position = SCNVector3(0,0,-0.5)
            sceneView.scene.rootNode.addChildNode(objNode)
            existence = true
        }
    }
}
