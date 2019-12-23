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
    
    override func update(acc:SCNVector3,gyro:SCNVector3){
        HookAcc = acc//using HookAcc.Z
        HookGryro = gyro//using HookGryro.X
    }
    var HookAcc = SCNVector3(0,0,0)
    var HookGryro = SCNVector3(0,0,0)
    var gyroX:CGFloat = 0
    var accZ:CGFloat = 0
    var seccount:Float = 0
    var WaitTime = Double.random(in: 1 ... 10)// ランダムな1から10を生成->待ち時間
    var calval:Float = 0
    var sendval:Int = 0

    //フッキングの判定と返す値を決定する関数
    func Hookingresult() {
        if (seccount > 15){//intervalseconds*15 = 0.5秒
            
            accZ = abs(accZ)//accZは負の値なので計算しやすいように正の値に変換する。
            
            calval = Float(gyroX * accZ)//取得した値を掛け算する
            
            calval /= 1.5//判定値のカウンタが10カウントを基準に測ったため
            
            switch calval {
                case 0..<10://1の判定
                    sendval = 1
                    break
                case 10..<130://2~7までの判定
                    calval = (calval+30)/20
                    sendval = Int(floor(calval))
                    break
                case 130..<150://8~9の判定
                    calval = (calval-50)/10
                    sendval = Int(floor(calval))
                    break
                case 150..<1000000://10の判定
                    sendval = 10
                    break
                default://0(動かしていない時)や、予期せぬ値
                    sendval = 0
                    break
            }
            //Gamestatusに値を引き渡す。(classの処理が全て終了)
            return gameStatus.HitCondition = sendval
            
        }else{
        //画面上の動き(acc.z)が上向き(-Z方向),画面の回転(gyro.x)が手前側(+X方向)の時に値を取得する。
            if (HookGryro.x >= 0 && HookAcc.z <= 0){
                gyroX += HookGryro.x
                accZ += HookAcc.z
                seccount += 1
            } else if (HookGryro.x < 0 && HookAcc.z <= 0){
                //accZのみが正しい値の場合
                accZ += HookAcc.z
                seccount += 1
            } else if (HookGryro.x >= 0 && HookAcc.z > 0){
                //gyroXが正しい値の場合
                gyroX += HookGryro.x
                seccount += 1
            } else {
                //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                //(動かしていない場合、処理が終わらないことを防ぐ為)
                seccount += 0.5
            }
        }
    }

    //ウキが沈む
    func FloatShinker(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTime) {
            //GameMnanagerにウキが沈んだことを伝える。(ウキが沈むというアクション)
            //Vizualizerにウキをどのくらい沈めたいかを通知
            //低音を流して振動で掛かったことを伝える。
            print("＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋魚が掛かった＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋")
            //ここで魚の情報が決定する。
            self.Hookingresult()
        }
    }
    
    override func touched() {
        state = .hooking
    }
    
    override func name() -> String {
        return "Hooking"
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
