//
//  ViewController.swift
//  fishing_ar
//
//  Created by Yuhei Akamine on 2019/12/05.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var gameController : GameController!
    let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
    let motionManager = CMMotionManager()
//    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        self.gameController = GameController(sceneRenderer: self.sceneView, view: self.sceneView)
        // Create a new scene
        //let scene = SCNScene(named: "Art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene

        sceneView.debugOptions = [.showFeaturePoints]
        

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameController.touchBegin()
        startSensorUpdates(intervalSeconds: 0.1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        gameController.touchEnd()
        gameController.status.isHolding=false
        motionManager.stopAccelerometerUpdates()
    }
    
    // モーションデータの取得を開始
    func startSensorUpdates(intervalSeconds:Double) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = intervalSeconds

            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.getMotionData(deviceMotion: motion!)

            })
        }
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

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor{
        // 平面ジオメトリを作成
        let geometry = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        geometry.materials.first?.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
            
        let lakeScene = SCNScene(named: "lake.scn",inDirectory: "Art.scnassets")
        // 平面ジオメトリを持つノードを作成
        var planeNode = SCNNode(geometry: geometry)
            
            if let dummyPlane = lakeScene?.rootNode.childNode(withName:"Plane",recursively: true){
                dummyPlane.scale=SCNVector3(0.04,0.04,0.04)
                planeNode=dummyPlane
                gameController.visualizer.lakeNode = planeNode
            }
        
        planeNode.name="plane"
            //x-z平面に合わせる
        planeNode.eulerAngles.x = -Float.pi*3/2
        //planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
            
            let position=SCNVector3(anchor.transform.columns.3.x,anchor.transform.columns.3.y,anchor.transform.columns.3.z)

        DispatchQueue.main.async(execute: {
            //self.gameController.visualizer.scene.rootNode.addChildNode(planeNode)
            // add planeNode to base
            // set baseNode position
            
            if let base = self.gameController.visualizer.scene.rootNode.childNode(withName: "base", recursively: true){
                base.position=position
                base.addChildNode(planeNode)
            }
 
            //node.addChildNode(planeNode)
            //self.gameController = GameController(sceneRenderer: self.sceneView, view: self.sceneView,planeNode: planeNode)
        })
    }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
        if anchor is ARImageAnchor{
        let position=SCNVector3(anchor.transform.columns.3.x,anchor.transform.columns.3.y,anchor.transform.columns.3.z)
        self.gameController.plane_pos(pos:position)
        if let base = self.gameController.visualizer.scene.rootNode.childNode(withName: "base", recursively: true){
            if base.childNode(withName: "plane", recursively: true) != nil{
            base.position=position
            }
        }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval){
        if(gameController.status.succeed){
            goResultView()
        }
        print(gameController.status.succeed)
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
    
    // モーションデータの取得（例としてコンソールへ出力）
    func getMotionData(deviceMotion:CMDeviceMotion) {
        //GameController のインスタンスに渡す.
        let ACC = SCNVector3(deviceMotion.userAcceleration.x,deviceMotion.userAcceleration.y,deviceMotion.userAcceleration.z)
        
        let GYRO = SCNVector3(deviceMotion.rotationRate.x,deviceMotion.rotationRate.y,deviceMotion.rotationRate.z)
        
        gameController.setGyro(gyro:GYRO)
        gameController.setAcc(acc:ACC)
    }
    
    //result画面へ遷移する関数
       func goResultView(){
           DispatchQueue.main.async{
               let storyboard: UIStoryboard = self.storyboard!
               
               let nextView = storyboard.instantiateViewController(withIdentifier: "ResultView")as! ResultViewController
            
               nextView.gameStatus=self.gameController.status
               
               self.present(nextView, animated: true, completion: nil)
           }
       }
}

//extension ViewController: AVAudioPlayerDelegate {
//    func playSound(name: String) {
//        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
//            print("音源ファイルが見つかりません")
//            return
//        }
//
//        do {
//            // AVAudioPlayerのインスタンス化
//            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
//
//            // AVAudioPlayerのデリゲートをセット
//            audioPlayer.delegate = self
//
//            // 音声の再生
//            audioPlayer.play()
//        } catch {
//        }
//    }
//}
