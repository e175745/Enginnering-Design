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
    var state: State = .preparing
    let WaitTimeVal:Double = 5.5
    var WaitStart:Bool = false
    var back:Bool = false

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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            self.visualizer.playSound(name: "finish")
            self.visualizer.showImage(name: "Finish.png", position: CGPoint(x:370,y:600), size:CGSize(width:600,height:600), showTime: 7)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.WaitTimeVal){
                self.back = true
            }
        }
    }
    
    //画面をタッチしたときに呼び出される関数
    override func touched() {
        if self.back==true{
            self.state = .GoBack
        }
    }
    
    // 現在の状態をテキストで返す関数
    override func name() -> String {
        return "BackScene("+stateDesc[state]!+")"
    }
    
    // 状態によって画面を遷移させる関数
    override func nextScene() -> GameScene? {
        if state == .GoBack {
            self.back = false
            return CastingScene(base: self)
        }else{
            return nil
        }
    }
}
