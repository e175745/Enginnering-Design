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
    // FightingScene開始時の時刻を取得
    let startDate = Date()
    var fishsize:Float = 0

    enum State {
        case start
        case fighting
        case successful
        case failed
    }

    var state: State = .start
    
    let stateDesc: [State:String] = [
        .start:"start",
        .fighting:"fighting",
        .successful:"successful",
        .failed:"failed"
    ]

    override func update(acc:SCNVector3,gyro:SCNVector3) {
        switch self.state {
        case .start:
            self.start()
            break
        case .fighting:
            self.timeLimit()
            self.fighting()
        default:
            break
        }
    }
    
    private func start(){
        self.visualizer.playSound(name: "fight_scene")
        self.state = .fighting
        //ここの「6」を変動することで近づく速度を変更可能である。
        fishsize = Float(round(self.gameStatus.FishSize / 6))
    }

    //stateがfightingの間、常に呼び出される関数
    private func fighting() {
        //ここに魚の暴れ具合を実装
        let randomX = Double.random(in: -0.02..<0.02)
        let randomZ = Double.random(in: 0..<0.02)
        let minusPow = SCNVector3(randomX,0,randomZ)
        self.visualizer.floatObject!.velocity = self.visualizer.floatObject!.velocity - minusPow
    }

    //画面にタッチしたときの呼び出される関数
    override func touched() {
        
        //オブジェクトとカメラの距離を求める材料
        let dx = self.visualizer.floatObject!.position.x - self.gameStatus.eyePoint.x
        let dy = self.visualizer.floatObject!.position.y - self.gameStatus.eyePoint.y
        let dz = self.visualizer.floatObject!.position.z - self.gameStatus.eyePoint.z
        //2点間距離(2次元)
        let distance = sqrtf(Float(dx*dx+dz*dz))
        //実際に移動するときに渡すベクトル
        //Fight中
        let newVelFight1 = self.visualizer.floatObject!.position - SCNVector3(dx/self.fishsize,0,dz/self.fishsize)
        let newVelFight2 = self.visualizer.floatObject!.position - SCNVector3(dx/(self.fishsize*2),0,dz/(self.fishsize*2))
        //成功したとき
        let newVelFinish = self.visualizer.floatObject!.position - SCNVector3(dx,dy*2,dz)
        // 指定距離に入ったらFighting終了それ以外は続行
        if distance < 0.1{
            print("End")
    
            self.visualizer.playSound(name: "nami")
            self.visualizer.floatObject!.velocity = SCNVector3()
            self.state = .successful
            return visualizer.updateVelocity(to: newVelFinish)
        }else if distance > 1{
            print("Push of if far away")
            return visualizer.updateVelocity(to: newVelFight2)
        }else{
            print("Push!")
            return visualizer.updateVelocity(to: newVelFight1)
        }
    }
    
    //時間制限を実装する関数
    private func timeLimit(){
        
        // 制限時間設定に必要な要素を取得
        let limit = Double(gameStatus.HitCondition) * 1.5
        //let limit = Double(5)
        // 現在時刻と開始時刻の差
        let time = Date().timeIntervalSince(startDate as Date)
        // タイマー
        let date_String = Date(timeIntervalSinceReferenceDate: time)
        // 制限時間
        let date_Limit = Date(timeIntervalSinceReferenceDate: limit)
        // 時間のみの表記に加工する
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        dateFormatter.dateFormat = "HH:mm:ss"
        
        
        // 確認用
        //print("=================")
        //print(gameStatus.HitCondition)
        print(limit)
        //print(dateFormatter.string(from: date_String as Date))
        //print(dateFormatter.string(from: date_Limit as Date))
        //print("=================")
        
        // 制限時間を超えたらBackSceneに行く
        if date_String >= date_Limit {
            print("Failed")
            self.state = .failed
        }
        
    }
    
    // 失敗したときに浮きの動きを止める
    private func failedMove(){
        self.visualizer.floatObject!.velocity += -self.visualizer.floatObject!.velocity
    }

    override func name() -> String {
        return "Fighting("+stateDesc[state]!+")"
    }

    override func nextScene() -> GameScene? {
        if state == .successful {
            //Result画面に遷移するのに必要な処理を書く
            self.visualizer.makeFish(FishName: "taiyaki")
            return nil
        }else if state == .failed{
            self.failedMove()
            return BackScene(base:self)
        }else {
            return nil
        }
    }
}


