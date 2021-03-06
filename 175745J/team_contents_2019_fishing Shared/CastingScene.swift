//
//  CastingScene.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class CastingScene: GameSceneBase {

    enum State {
        case preparing
        case holding
        case throwing
        case sceneCompleted
        case sceneFailed
    }
    
    var state: State = .preparing
    let stateDesc: [State:String] = [
        .preparing:"preparing",
        .holding:"holding",
        .throwing:"throwing",
        .sceneCompleted:"scene completed",
        .sceneFailed:"scene Failed"
    ]
    let DISTACE_FLOAT_HOLD = SCNFloat(0.1)
    var THROWING_VELO = SCNFloat(0)
    let GRAVITY = SCNVector3(0,-0.98,0)
    
    override func prepare() {
        state = .preparing
    }
    
    override func update(acc:SCNVector3,gyro:SCNVector3) {
        self.THROWING_VELO=SCNFloat(acc.z)
        switch state {
        case .preparing:
            preparing()
        case .holding:
            holding()
        case .throwing:
            throwing()
        default:
            break
        }
    }
    
    private func preparing() {
    self.visualizer.showImage(name:"hold_only.png",position:CGPoint(x:500,y:750),size:CGSize(width:210,height:200),showTime:0.1)
    }
    
    private func holding() {
        visualizer.moveFloat(to: gameStatus.eyePoint + gameStatus.viewVector * DISTACE_FLOAT_HOLD)
        visualizer.floatObject!.gravity = GRAVITY
    }
    
    private func throwing() {
        let FLOAT_DEPTH = 0 as SCNFloat
        if visualizer.floatObject!.position.y < FLOAT_DEPTH {
            if visualizer.doesOverlapWithLake{
                state = .sceneCompleted
                visualizer.floatObject!.velocity = SCNVector3()
                visualizer.floatObject!.gravity = SCNVector3()
            }else{
                state = .sceneFailed
                visualizer.floatObject!.velocity = SCNVector3()
                visualizer.floatObject!.gravity = SCNVector3()
            }
            
        }
    }
    
    override func name() -> String {
        return "casting("+stateDesc[state]!+")"
    }
    
    override func touched() {
        if state == .preparing {
            state = .holding
        }
    }
    
    override func released() {
        //visualizer.playSound(1001)
        if state == .holding {
            state = .throwing
            visualizer.floatObject!.velocity = gameStatus.viewVector * THROWING_VELO
        }
    }
    
    override func nextScene() -> GameScene? {
        if state == .sceneCompleted {
            return HookingScene(base: self)
        }else if(state == .sceneFailed){
            return BackScene(base: self)
        }else {
            return nil
        }
    }
}
