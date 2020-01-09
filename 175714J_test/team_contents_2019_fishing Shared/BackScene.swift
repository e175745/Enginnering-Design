//
//  BackScene.swift
//  team_contents_2019_fishing
//
//  Created by 仲西智章 on 2020/01/09.
//  Copyright © 2020 Tomoaki Nakanishi. All rights reserved.
//

import Foundation
import SceneKit

class BackScene: GameSceneBase {
    
    enum State {
        case preparing
        case GoBack
    }
    // let retryButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var state: State = .preparing
    let WaitTimeVal:Double = 10
    var WaitStart = false
    let dummyFloat = SCNNode()
    
    let stateDesc: [State:String] = [
        .preparing:"preparing",
        .GoBack:"GoBack"
    ]
    
//    self.gameStatus.FishLeaves = true
    
    override func update(acc:SCNVector3,gyro:SCNVector3) {
        switch self.state {
        case .preparing:
            self.visualizer.removeObject = true
            self.visualizer.makeObject(with: dummyFloat)
            if(WaitStart==false){
                self.WaitTime()
            }
            break
        case .GoBack:
            break
        }
    }
    
    func WaitTime(){
        WaitStart = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTimeVal){
            self.touched()
        }
    }
    
    //画面をタッチしたときに呼び出される関数
    override func touched() {
        self.state = .GoBack
        // visualizer.hitTest(with: String(stateDesc[state]!), at:CGPoint)
    }
    
    // 現在の状態をテキストで返す関数
    override func name() -> String {
        return "BackScene("+stateDesc[state]!+")"
    }
    
    // 状態によって画面を遷移させる関数
    override func nextScene() -> GameScene? {
        if state == .GoBack {
            //Result画面に遷移するのに必要な処理を書く
            return CastingScene(base:self)
        }else{
            return nil
        }
    }
}
