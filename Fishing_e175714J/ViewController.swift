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
protocol GameScene {
    func tap()
    func release()
    func update(cameraNode:SCNNode,acc:SCNVector3,rot:SCNVector3)
}

class Visualizer{
    init(){
        let objGeometry = SCNSphere(radius: 0.05)
        // Cubeのマテリアルを設定
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.diffuse.intensity = 0.8;
        objGeometry.materials = [material]
        floatNode=SCNNode(geometry: objGeometry)
    }

    func moveFloat(to pos:SCNVector3){
        
    }
    func setFloatVel(_ vel:SCNVector3){
        
    }
    func update(){
        
    }
    var floatPos:SCNVector3{get{return floatNode.position}}
    let floatNode:SCNNode
    var floatVel:SCNVector3
}
*/

//ここから仲西
class Hooking{
    // CMMotionManagerのインスタンスを生成
    let motionManager = CMMotionManager()
    
    var gyroX:Double = 0
    var accZ:Double = 0
    var seccount:Double = 0
    var WaitTime = Double.random(in: 1 ... 10)// 1から10を生成
    var calval:Double = 0
    var sendval:Int = 0
    
    // モーションデータの取得を開始
    func startSensorUpdates(intervalSeconds:Double) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = intervalSeconds
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.getMotionData(deviceMotion: motion!)
            })
        }
    }

    // モーションデータの取得（例としてコンソールへ出力）
    func getMotionData(deviceMotion:CMDeviceMotion) {
        //intervalSeconds * 10 = 取得可能時間
        //今回は　0.05*10 = 0.5 秒
        if (seccount > 10){
            //処理を終える
            self.motionManager.stopDeviceMotionUpdates()
            accZ = fabs(accZ)//accZは負の値なので計算しやすいように正の値に変換する。
            /*
            桁数が多いので四捨五入してみる
            gyroX = round(gyroX) / 1000
            accZ = round(accZ) / 1000
            */
            //print("取得したgyroXの値は \(gyroX) です")
            //print("取得したaccZの値は \(accZ) です")
            //print("取得したsendvalの値は \(sendval) です")
            
            //取得した値を掛け算する
            calval = gyroX * accZ
            
            switch calval {
                case 0..<10:// 0から10未満。
                    sendval = 1
                case 10..<30:
                    sendval = 2
                case 30..<50:
                    sendval = 3
                case 50..<70:
                    sendval = 4
                case 70..<90:
                    sendval = 5
                case 90..<110:
                    sendval = 6
                case 110..<130:
                    sendval = 7
                case 130..<140:
                    sendval = 8
                case 140..<150:
                    sendval = 9
                case 150..<1000000:
                    sendval = 10
            default:
              sendval = 0
            }
            print("判定終了 受け渡す値は\(sendval)です")
            
        }else{
            //画面上の動き(acc_z)が上向き(-Z方向),画面の回転(gyro_x)が手前側(+X方向)の時に値を取得する。
            if (deviceMotion.rotationRate.x > 0 && deviceMotion.userAcceleration.z < 0){
                gyroX += deviceMotion.rotationRate.x
                accZ += deviceMotion.userAcceleration.z
                seccount += 1
            } else if (deviceMotion.rotationRate.x < 0 && deviceMotion.userAcceleration.z < 0){
                //accZのみが正しい値の場合
                accZ += deviceMotion.userAcceleration.z
                seccount += 1
            } else if (deviceMotion.rotationRate.x > 0 && deviceMotion.userAcceleration.z > 0){
                //gyroXが正しい値の場合
                gyroX += deviceMotion.rotationRate.x
                seccount += 1
            } else {
                //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                seccount += 0.5
            }
            //print(gyroX)
            //print(accZ)
        }
    }
    
    //待機して以上のクラスを実行する関数
    func sleep(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTime) {
            //ここにウキが沈むというアクション
            //低音を流して振動で掛かったことを伝える。
            print("＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋魚が掛かった＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋")
            self.startSensorUpdates(intervalSeconds:0.05)
        }
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
        //これからやりたいこととしては魚がかかるという動作の後(ウキが沈む)にこの関数を呼び出して、その後端末の動かし具合によって魚のかかり具合を出力すれば良い。
            //関数呼び出し、0.05秒ごとにattitudeなどのデータを出力(print)する。
            let cl = Hooking()
            cl.sleep()
            //ここでは「set」ボタンを押した時から0.5秒ごとにattitudeなどのデータを出力(print)する。
        
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
            
            // Cubeの座標を設定
            objNode.position = SCNVector3(0,0,-0.5)
            sceneView.scene.rootNode.addChildNode(objNode)
            existence = true
        }
    }
}
