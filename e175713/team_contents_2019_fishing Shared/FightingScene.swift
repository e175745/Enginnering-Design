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
        case touched
        case successful
        case failed
    }
    
    var state: State = .fighting
    let stateDesc: [State:String] = [
        .fighting:"fighting",
        .touched:"touched",
        .successful:"successful",
        .failed:"failed"
    ]
    
    override func update() {
        switch state {
        case .fighting:
            fighting()
        default:
            break
        }
    }
    
    let THROWING_VELO = SCNFloat(5)
    
    private func fighting() {
        //ここに魚の暴れ具合を実装予定
        //visualizer.floatObject!.velocity = -gameStatus.viewVector
    }
    
    override func touched() {
        state = .touched
        
        let dx = -(visualizer.floatObject!.position.x - gameStatus.eyePoint.x)
        let dy = -(visualizer.floatObject!.position.y - gameStatus.eyePoint.y)
        let dz = -(visualizer.floatObject!.position.z - gameStatus.eyePoint.z)
        let distance = sqrtf(Float(dx*dx+dz*dz))
        let move_x = Float(dx / 10 )
        let move_z = Float(dz / 10 )
        let fightMove = SCNVector3(move_x,0,move_z)
        let finishMove = SCNVector3(dx,dy,dx-2.0)
        
        let newPosFight = visualizer.floatObject!.position + fightMove
        
        let newPosFinish = visualizer.floatObject!.position + finishMove
        
        // 指定距離に入ったらFighting終了それ以外は続行
        if distance < 10{
            state = .successful
            return visualizer.moveFloat(to: newPosFinish)
            //visualizer.floatObject!.velocity = newPosFinish
        }else{
            state = .fighting
            if visualizer.floatObject!.position.x > newPosFight.x || visualizer.floatObject!.position.z > newPosFight.z{
                visualizer.floatObject!.velocity = SCNVector3()
            }else{
                return visualizer.updateVelocity(to: newPosFight)
                //visualizer.floatObject!.velocity = newPosFight
            }
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
            return nil
        }else if state == .failed{
            return CastingScene(base:self)
        }else {
            return nil
        }
    }
    
}
