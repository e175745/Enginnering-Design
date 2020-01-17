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
import AudioToolbox

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
        scene.rootNode.addChildNode(lightNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        /*
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!
         */
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    func makeLine(_ from:SCNVector3,_ to:SCNVector3){
        if let oldLineObject = sceneView.scene.rootNode.childNode(withName:"line",recursively: true){
            oldLineObject.removeFromParentNode()
            }
        let source = SCNGeometrySource(vertices: [from, to])
        let indices: [Int32] = [0, 1]
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let line = SCNGeometry(sources: [source], elements: [element])
        line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.blinn
        let dummyLine = SCNNode(geometry: line)
        dummyLine.geometry?.firstMaterial?.emission.contents = UIColor.white
        dummyLine.name="line"
        sceneView.scene.rootNode.addChildNode(dummyLine)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let camera = sceneView.pointOfView else {
            return
        }
        let cameraPos = SCNVector3Make(0, 0, -0.5)
        let position = camera.convertPosition(cameraPos, to: nil)
        if existence{
            if let objNode = sceneView.scene.rootNode.childNode(withName: "Float", recursively: true){
                objNode.position = position
            }
        }
        if let objNode = sceneView.scene.rootNode.childNode(withName: "Float", recursively: true){
            let cubePosi = objNode.position
            let homePosi = SCNVector3(position.x,position.y+0.3,position.z)
            makeLine(homePosi,cubePosi)
            }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
            // 平面ジオメトリを作成
            //let geometry = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
        height: CGFloat(planeAnchor.extent.z))
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
    
    @objc func tapView(sender: UIGestureRecognizer) {
        existence = false
        
        if let objNode = sceneView.scene.rootNode.childNode(withName: "Float", recursively: true){
    
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
                if result.node.name == "Float"
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
        // キャスト音声：1001
        //AudioServicesPlaySystemSoundWithCompletion(1001) {}
        
        let soundUrl = Bundle.main.url(forResource: "nc2039", withExtension: "mp3")
        //let soundUrl = Bundle.main.url(forResource: "nc155740", withExtension: "wav")
        //カスタムサウンドのサウンドIDを保存するための変数
        var soundID: SystemSoundID = 0
        //サウンドIDを取得
        AudioServicesCreateSystemSoundID(soundUrl! as CFURL, &soundID)
        //取得したサウンドIDを指定して再生
         AudioServicesPlaySystemSoundWithCompletion(soundID) {}
        
        if existence{
            if let objNode = sceneView.scene.rootNode.childNode(withName: "Float", recursively: true){
                
                let homePosi = SCNVector3(0,0,-0.5)
                let action = SCNAction.move(to: homePosi, duration: 1)
                objNode.runAction(action)
            }
        }else{
        
            // Cubeを作成
            // let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            /*
            let obj = SCNSphere(radius: 0.05)
            let objNode = SCNNode(geometry: obj)
            objNode.name = "obj"
            
            
            // Cubeのマテリアルを設定
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            material.diffuse.intensity = 0.8;
            objNode.geometry?.materials = [material]
            */


            let floatScene = SCNScene(named: "Float.scn", inDirectory: "art.scnassets")
            if let objNode = floatScene?.rootNode.childNode(withName: "Float", recursively: true){
                objNode.scale = SCNVector3(0.01, 0.01, 0.01)
                // Cubeの座標を設定
                objNode.position = SCNVector3(0,0,-0.5)
                sceneView.scene.rootNode.addChildNode(objNode)
                existence = true
            }
        }
    }
    @IBAction func Back(_ sender: Any) {
        self.performSegue(withIdentifier: "toMenu", sender: nil)
    }
    
}
