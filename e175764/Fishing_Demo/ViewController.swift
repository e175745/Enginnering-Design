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
import CoreMotion

class objectNode: SCNNode{
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init() {
    super.init()
    let objGeometry = SCNSphere(radius: 0.05)
    geometry=objGeometry
    name = "obj"
    
    // Cubeのマテリアルを設定
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.red
    material.diffuse.intensity = 0.8;
    geometry?.materials = [material]
    let objshape=SCNPhysicsShape(geometry: objGeometry, options: nil)
    let objbody=SCNPhysicsBody(type: .static, shape: objshape)
    objbody.restitution = 1.0
    physicsBody = objbody
    }
}

class PlaneNode: SCNNode{
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
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

    
    @IBAction func Sinker(_ sender: Any) {
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
            let action1 = SCNAction.moveBy(x: 0, y: -0.3, z: 0, duration: 0.5)
           
           // let action2 = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 1)
            objNode.runAction(
                SCNAction.sequence([
                action1,
                //action2,
                ])
            )
        }
    }
    
    //shake motion
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
            let action1 = SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 0.5)
            objNode.runAction(
                SCNAction.sequence([
                action1,
                ])
            )
        }
    }

    let motionManager = CMMotionManager()
    
    func getMotionData(deviceMotion:CMDeviceMotion) {
        print("attitudeX:", deviceMotion.attitude.pitch)
        print("attitudeY:", deviceMotion.attitude.roll)
        print("attitudeZ:", deviceMotion.attitude.yaw)
        print("gyroX:", deviceMotion.rotationRate.x)
        print("gyroY:", deviceMotion.rotationRate.y)
        print("gyroZ:", deviceMotion.rotationRate.z)
        print("gravityX:", deviceMotion.gravity.x)
        print("gravityY:", deviceMotion.gravity.y)
        print("gravityZ:", deviceMotion.gravity.z)
        print("accX:", deviceMotion.userAcceleration.x)
        print("accY:", deviceMotion.userAcceleration.y)
        print("accZ:", deviceMotion.userAcceleration.z)
    }
    // モーションデータの取得を開始
    func startSensorUpdates(intervalSeconds:Double) {
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        if motionManager.isDeviceMotionAvailable{
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.getMotionData(deviceMotion: motion!)
            })
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
           guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
       
           // 平面ジオメトリを作成
           let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                   height: CGFloat(planeAnchor.extent.z))
           geometry.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)

           // 平面ジオメトリを持つノードを作成
           let planeNode = SCNNode(geometry: geometry)
               //x-z平面に合わせる
           planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)

           DispatchQueue.main.async(execute: {
               // 検出したアンカーに対応するノードに子ノードとして持たせる
               node.addChildNode(planeNode)
           })
       }
       
       // 更新されたとき
       func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
           guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}

           DispatchQueue.main.async(execute: {
               // 平面ジオメトリのサイズを更新
               for childNode in node.childNodes {
                   guard let plane = childNode.geometry as? SCNPlane else {continue}
                   plane.width = CGFloat(planeAnchor.extent.x)
                   plane.height = CGFloat(planeAnchor.extent.z)
                   break
               }
           })
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 水平表示
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
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
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    
    @objc func tapView(sender: UIGestureRecognizer) {
        existence = false
        
        if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
    
            let location = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(location, types: .existingPlane)
        
            if let result = hitTestResult.first {
                objNode.physicsBody=SCNPhysicsBody()
                // オブジェクトを飛ばす
                let target = SCNVector3Make(
                    result.worldTransform.columns.3.x,
                    result.worldTransform.columns.3.y + 0.1,
                    result.worldTransform.columns.3.z)
                let action = SCNAction.move(to: target, duration: 2)
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
        startSensorUpdates(intervalSeconds: 1.0)
        if existence{
            if let objNode = sceneView.scene.rootNode.childNode(withName: "obj", recursively: true){
                
                let homePosi = SCNVector3(0,0,-0.5)
                let action = SCNAction.move(to: homePosi, duration: 1)
                objNode.runAction(action)
            }
        }else{
            // Cubeを作成
            // let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            let objNode = objectNode()
            sceneView.scene.rootNode.addChildNode(objNode)
            existence = true
        }
    }
}
