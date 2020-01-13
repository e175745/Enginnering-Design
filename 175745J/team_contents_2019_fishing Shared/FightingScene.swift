//
//  FightingScene.swift
//  team_contents_2019_fishing macOS
//
//  Created by 森健汰 on 2019/12/22.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class FightingScene: GameSceneBase {

    enum State {
        case fighting
        case successful
        case failed
    }

    
    var state: State = .fighting
    
    let stateDesc: [State:String] = [
        .fighting:"fighting",
        .successful:"successful",
        .failed:"failed"
    ]

    override func update(acc:SCNVector3,gyro:SCNVector3) {
        switch state {
        case .fighting:
            fighting()
        default:
            break
        }
    }

    //stateがfightingの間、常に呼び出される関数
    private func fighting() {
        //ここに魚の暴れ具合を実装
        let randomX = Double.random(in: -0.02..<0.02)
        let randomZ = Double.random(in: 0..<0.02)
        let minusPow = SCNVector3(randomX,0,randomZ)
        visualizer.floatObject!.velocity = visualizer.floatObject!.velocity - minusPow
    }

    //画面にタッチしたときの呼び出される関数
    override func touched() {
        //オブジェクトとカメラの距離を求める材料
        let dx = visualizer.floatObject!.position.x - gameStatus.eyePoint.x
        let dy = visualizer.floatObject!.position.y - gameStatus.eyePoint.y
        let dz = visualizer.floatObject!.position.z - gameStatus.eyePoint.z
        //2点間距離(2次元)
        let distance = sqrtf(Float(dx*dx+dz*dz))
        //実際に移動するときに渡すベクトル
        //Fight中
        let newPosFight = visualizer.floatObject!.position - SCNVector3(dx/2,0,dz/2)
        //成功したとき
        let newPosFinish = visualizer.floatObject!.position - SCNVector3(dx,dy*2,dz)
        // 指定距離に入ったらFighting終了それ以外は続行
        if distance < 0.1{
            print("End")
            state = .successful
            visualizer.floatObject!.velocity = SCNVector3()
            return visualizer.updateVelocity(to: newPosFinish)
        }else{
            print("Push!")
            return visualizer.updateVelocity(to: newPosFight)
        }
    }
    //時間制限を実装する関数
    private func timeLimit(){
    }

    override func name() -> String {
        return "Fighting("+stateDesc[state]!+")"
    }

    override func nextScene() -> GameScene? {
        if state == .successful {
            self.visualizer.playSound(name: "MGS_!")
            
            return nil
        }else if state == .failed{
            return BackScene(base:self)
        }else {
            return nil
        }
    }
}


