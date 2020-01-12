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
    let WaitTimeVal:Double = 6
    var WaitStart = false

    let stateDesc: [State:String] = [
        .preparing:"preparing",
        .GoBack:"GoBack"
    ]
    
    
    override func update(acc:SCNVector3,gyro:SCNVector3) {
        switch self.state {
        case .preparing:
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
            self.visualizer.playSound(name: "!")
            self.state = .GoBack
        }
    }
    
    //ウキの削除
    func DeleteObject(){
    }
    
    //画面をタッチしたときに呼び出される関数
    override func touched() {
    }
    
    // 現在の状態をテキストで返す関数
    override func name() -> String {
        return "BackScene("+stateDesc[state]!+")"
    }
    
    // 状態によって画面を遷移させる関数
    override func nextScene() -> GameScene? {
        if state == .GoBack {
            return CastingScene(base: self)
        }else{
            return nil
        }
    }
}

