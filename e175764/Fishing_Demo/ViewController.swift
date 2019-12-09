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
/*
class UIController: UIViewController{
    func heimenn_kennti(){
        return heimen_anchor
    }
}
 */

class PlaneNode: SCNNode{
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        geometry?.materials = [planeMaterial]
        
        let planeShape = SCNPhysicsShape(geometry: geometry!, options: nil)
        let planeBody = SCNPhysicsBody(type: .static, shape: planeShape)
        physicsBody = planeBody
        
        let x = CGFloat(anchor.center.x)
        let y = CGFloat(anchor.center.y)
        let z = CGFloat(anchor.center.z)
        
        position = SCNVector3(x,y,z)
        eulerAngles.x = -.pi / 2
    }
    func update(anchor: ARPlaneAnchor) {
           
           (geometry as! SCNPlane).width = CGFloat(anchor.extent.x)
           (geometry as! SCNPlane).height = CGFloat(anchor.extent.z)
    
           let planeShape = SCNPhysicsShape(geometry: geometry!, options: nil)
           let planeBody = SCNPhysicsBody(type: .static, shape: planeShape)
           physicsBody = planeBody
           
           let x = CGFloat(anchor.center.x)
           let y = CGFloat(anchor.center.y)
           let z = CGFloat(anchor.center.z)
           position = SCNVector3(x,y,z)
       }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    let motionManager = CMMotionManager()
    let game = GameManager()
    let visual = Visualizer()
    @IBAction func startCasting(_ sender: UIButton) {
        startSensorUpdates(intervalSeconds: 0.01)
    }
        
    @IBAction func endCasting(_ sender: UIButton) {
        motionManager.stopAccelerometerUpdates()
    }
    
    @IBOutlet var sceneView: ARSCNView!
    
    var existence = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //Visualizerがインスタンス生成
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
        sceneView.scene = visual.scene
        
        // デバックオプション
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        sceneView.addGestureRecognizer(tapGesture)
        
        // longPress
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressView))
        sceneView.addGestureRecognizer(longPressGesture)
    
        // オムニライトを追加
        /*
        let lightNode = SCNNode()
        lightNode .light = SCNLight()
        lightNode .light!.type = .omni
        lightNode .position = SCNVector3(x: 0, y: 10, z: 10)
        visual.scene.rootNode.addChildNode(lightNode )
        */
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
    
    func startSensorUpdates(intervalSeconds:Double) {
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        if motionManager.isDeviceMotionAvailable{
            motionManager.startDeviceMotionUpdates(
            to: OperationQueue.current!,
            withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.outputAccelData(deviceMotion: motion!)
            })
        }
    }
    
    func outputAccelData(deviceMotion: CMDeviceMotion){
        //GameManagerのフィールド変数に加速度を渡す(SCNVector3)
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
        let planeNode = PlaneNode(anchor: planeAnchor)
           DispatchQueue.main.async(execute: {
               node.addChildNode(planeNode)
           })
        }
       }
       
       // 更新されたとき
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async(execute: {
            // 平面ジオメトリのサイズを更新
            if let planeAnchor = anchor as? ARPlaneAnchor, let planeNode = node.childNodes[0] as? PlaneNode {
                   // ノードの位置及び形状を修正する
                    planeNode.update(anchor: planeAnchor)
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

            if let camera = sceneView.pointOfView { // カメラを取得
                    // カメラの向いてる方向を計算
                    let mat = camera.transform
                    let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32 + 0.1, -1 * mat.m33)
                    // 上方向に位置を補正
                objNode.physicsBody?.isAffectedByGravity=true
                    objNode.physicsBody?.applyForce(dir, asImpulse: true)
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

}
