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


//変面けんち
//DeviceMotion

class UIController: ViewController{
    // カメラポジションを返す関数
    func cameraNode(_ session: ARSession, didUpdate frame: ARFrame) -> SCNNode {
        if let camera = sceneView.pointOfView { // カメラを取得
            /*
            // カメラの向いてる方向を計算
            let mat = camera.transform
            let cameraPosition = SCNVector3(mat.m31, mat.m32, mat.m33)
            return cameraPosition
            */
            return camera
        }
        return SCNNode()
    }
    
    func sendCamera()->SCNNode{
        return camera
    }
    
    func deviceAccelarate()->SCNVector3{
        return deviceAcc
    }
    
    func deviceRotation()->SCNVector3{
        return deviceRot
    }
    
    // 平面検知する関数
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
   
}

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
        
        let x = CGFloat(anchor.center.x)
        let y = CGFloat(anchor.center.y)
        let z = CGFloat(anchor.center.z)
        
        position = SCNVector3(x,y,z)
        eulerAngles.x = -.pi / 2
    }
    func update(anchor: ARPlaneAnchor) {
           
           (geometry as! SCNPlane).width = CGFloat(anchor.extent.x)
           (geometry as! SCNPlane).height = CGFloat(anchor.extent.z)
           
           let x = CGFloat(anchor.center.x)
           let y = CGFloat(anchor.center.y)
           let z = CGFloat(anchor.center.z)
           position = SCNVector3(x,y,z)
    }
}

//ViewContoller に必要な機能.
//viewDid_load
//ボタンの制御



class ViewController: UIViewController, ARSCNViewDelegate {
    var deviceRot=SCNVector3(0,0,0)
    var deviceAcc=SCNVector3(0,0,0)
    var camera=SCNNode()
    let motionManager = CMMotionManager()
    let game = GameManager()
    let visual = Visualizer()
    
    func startSensorUpdates(intervalSeconds:Double) {
        motionManager.deviceMotionUpdateInterval = intervalSeconds
        if motionManager.isDeviceMotionAvailable{
            motionManager.startDeviceMotionUpdates(
            to: OperationQueue.current!,
            withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.setRot(deviceMotion: motion!)
                self.setAcc(deviceMotion: motion!)
            })
        }
    }
    // デバイスの加速度を返す関数
    func setAcc(deviceMotion: CMDeviceMotion){
        let x=deviceMotion.userAcceleration.x
        let y=deviceMotion.userAcceleration.y
        let z=deviceMotion.userAcceleration.z
        deviceAcc=SCNVector3(x,y,z)
    }
    // デバイスの角速度を返す関数
    func setRot(deviceMotion: CMDeviceMotion){
        //GameManagerのフィールド変数に加速度を渡す(SCNVector3)
        let x=deviceMotion.rotationRate.x
        let y=deviceMotion.rotationRate.y
        let z=deviceMotion.rotationRate.z
        deviceRot=SCNVector3(x,y,z)
    }
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
        // オムニライトを追加
        /*
        let lightNode = SCNNode()
        lightNode .light = SCNLight()
        lightNode .light!.type = .omni
        lightNode .position = SCNVector3(x: 0, y: 10, z: 10)
        visual.scene.rootNode.addChildNode(lightNode )
        */
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 水平表示
        configuration.planeDetection = .horizontal
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

}
