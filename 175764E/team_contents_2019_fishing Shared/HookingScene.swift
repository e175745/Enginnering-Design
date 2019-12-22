//
//  HookingScene.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class HookingScene: GameSceneBase {
    enum State {
        case wating
        case hooking
    }
    
    var state = State.wating
    
    override func nextScene() -> GameScene? {
        if state == .hooking {
            return ResultSceneDummy(base: self)
        }else {
            return nil
        }
    }
    
    override func touched() {
        state = .hooking
    }
    
    override func name() -> String {
        return "Hooking"
    }
    
    override func update(acc: SCNVector3, gyro: SCNVector3) {
        print(acc)
        print(gyro)
    }
}


class ResultSceneDummy: GameSceneBase {
    override func nextScene() -> GameScene? {
        return nil
    }
    
    override func name() -> String {
        return "result scene"
    }
}
