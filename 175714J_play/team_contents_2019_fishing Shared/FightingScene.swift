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
    
    var fishsize1:Float = 0
    var fishsize2:Float = 0
    var limit_start:Double = 0
    let WaitTimeVal:Double = 5
    var limit:Double = 0
    
    let fishTypeList: [String] = ["","takasago","aobudai","tatiuo","rounin","taiyaki"]
    var FishTypeSmall = Int.random(in:1 ... 3)
    var FishTypeNormal = Int.random(in:2 ... 4)
    var FishTypeBig = Int.random(in:3 ... 5)

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
        //ここの「6」を変動することで近づく速度を変更可能である。
        self.fishsize1 = Float(round(self.gameStatus.FishSize / 10))
        self.fishsize2 = Float(round(self.gameStatus.FishSize / 7))
        self.state = .fighting
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
        //let newVelFight1 = self.visualizer.floatObject!.position - SCNVector3(dx/3,0,dz/3)
        //let newVelFight2 = self.visualizer.floatObject!.position - SCNVector3(dx/6,0,dz/6)
        let newVelFight1 = self.visualizer.floatObject!.position - SCNVector3(dx/self.fishsize1,0,dz/self.fishsize1)
        let newVelFight2 = self.visualizer.floatObject!.position - SCNVector3(dx/self.fishsize2,0,dz/self.fishsize2)
        //成功したとき
        let newVelFinish = self.visualizer.floatObject!.position - SCNVector3(dx,dy*2,dz)
        // 指定距離に入ったらFighting終了それ以外は続行
        if distance < 0.15{
//            print("End")
            self.visualizer.playSound(name: "nami")
            self.state = .successful

//            print("float:", self.visualizer.floatObject!.position.y)
//            print("camera:", self.gameStatus.eyePoint.y)
            /*
            if self.visualizer.floatObject!.position.y >= 0{//self.gameStatus.eyePoint.y{
                print("stop")
                self.failedMove()
            }else{
                return visualizer.updateVelocity(to: newVelFinish)
            }
            */
            return visualizer.updateVelocity(to: newVelFinish)
        }else if distance > 1{
            //print("Push of if far away")
            return visualizer.updateVelocity(to: newVelFight2)
        }else{
            //print("Push!")
            return visualizer.updateVelocity(to: newVelFight1)
        }
    }
    
    //時間制限を実装する関数
    private func timeLimit(){
        
        // 制限時間設定に必要な要素を取得
        if self.gameStatus.HitCondition>7{
            limit = Double(self.gameStatus.HitCondition) * 3
        }else{
            limit = Double(self.gameStatus.HitCondition) * 1.5
        }
        
//        let limit = Double(20)
        // 現在時刻と開始時刻の差
        let time = Date().timeIntervalSince(self.startDate as Date)
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
        //print(limit)
        //print(dateFormatter.string(from: date_String as Date))
        //print(dateFormatter.string(from: date_Limit as Date))
        //print("=================")
        
        // 制限時間を超えたらBackSceneに行く
        if date_String >= date_Limit {
//            print("Failed")
            self.state = .failed
        }
        
    }
    
    // 失敗したときに浮きの動きを止める
    private func failedMove(){
        self.visualizer.floatObject!.velocity -= self.visualizer.floatObject!.velocity
    }

    override func name() -> String {
        return "Fighting("+stateDesc[state]!+")"
    }

    override func nextScene() -> GameScene? {
        if state == .successful {
//            self.number = Int(floor((Double(self.gameStatus.FishRarity)+1)/2))
            //print("List number:" + String(self.number))
            //print(fishTypeList[self.number])
            switch self.gameStatus.FishRarity {
            case 1..<4:
                self.visualizer.makeFish(FishName: self.fishTypeList[self.FishTypeSmall])
            case 4..<7:
                self.visualizer.makeFish(FishName: self.fishTypeList[self.FishTypeNormal])
            case 7..<10:
                self.visualizer.makeFish(FishName: self.fishTypeList[self.FishTypeBig])
            case 10:
                self.visualizer.makeFish(FishName: self.fishTypeList[5])
            default:
                break
            }
            
            if self.visualizer.floatObject!.position.y >= 0.15{
                self.failedMove()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.WaitTimeVal){
                //5sec後に遷移
                //ここにresult画面に遷移する処理を書く
//                print("result")
                print(self.gameStatus.FishRarity,self.gameStatus.FishSize)
            }
            //return resultScene
            return nil
        }else if state == .failed{
            self.failedMove()
            return BackScene(base:self)
        }else {
            return nil
        }
    }
}
