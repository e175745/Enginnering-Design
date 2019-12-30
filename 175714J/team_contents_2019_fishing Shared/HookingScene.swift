//
//  HookingScene.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 仲西智章. All rights reserved.
//

import Foundation
import SceneKit

class HookingScene: GameSceneBase {
    var HookAcc = SCNVector3(0,0,0)
    var HookGryro = SCNVector3(0,0,0)
    var gyroX:Float = 0
    var accZ:Float = 0
    var seccount:Float = 0
    var WaitTime = Double.random(in: 1 ... 10)// ランダムな1から10を生成->待ち時間
    var Fishrarity = Int.random(in: 0 ... 10)//魚のレア度をランダムに決定
    var calval:Float = 0
    var sendval:Int = 0
    var waitend:Int = 0
    //var Hookend:Int = 0
    
    enum State {//処理のグループ分け
        case waiting
        case hooking
        case hookingend
    }
    
    var state = State.waiting
    
    override func nextScene() -> GameScene? {
        if state == .hookingend {
            return ResultSceneDummy(base: self)//ここをFightにしてあげる
        }else {
            return nil
        }
    }
    
    override func update(acc:SCNVector3,gyro:SCNVector3){
        HookAcc = acc//using HookAcc.Z
        HookGryro = gyro//using HookGryro.X
        switch self.state{
            case .waiting:
                if(waitend == 0){
                    self.waittimer()
                }
                break
            case .hooking:
//画面上の動き(acc.z)が上向き(-Z方向),画面の回転(gyro.x)が手前側(+X方向)の時に値を取得する。
                if(seccount < 50){//intervalseconds(1F)*15 = 0.5秒
                    if (HookGryro.x >= 0 && HookAcc.z <= 0){
                        gyroX += HookGryro.x
                        accZ += HookAcc.z
                        seccount += 1
                        print("+++++++ gyroX=\(gyroX) +++++++")
                        print("+++++++ accZ=\(accZ) +++++++")
                    } else if (HookGryro.x < 0 && HookAcc.z <= 0){
                        //accZのみが正しい値の場合
                        accZ += HookAcc.z
                        seccount += 1
                        print("+++++++ accZ=\(accZ) +++++++")
                    } else if (HookGryro.x >= 0 && HookAcc.z > 0){
                        //gyroXが正しい値の場合
                        gyroX += HookGryro.x
                        seccount += 1
                        print("+++++++ gyroX=\(gyroX) +++++++")
                    } else {
                        //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                        //(動かしていない場合、処理が終わらないことを防ぐ為)
                        seccount += 0.5
                        print("+++++++++++ miss +++++++++++")
                    }
                }else if (seccount >= 50){//終了時(0.5秒後)にHookingresultを呼び出す
                    self.Hookingresult()
                    break
                }else{
                    print("Hookingクラスのseccountが正しい動作をしていません")
                    break
            }
        case .hookingend:
            break
        }
    }
    func waittimer(){
        waitend = 50000
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTime) {
            //Vizualizerにウキをどのくらい沈めたいかを通知
            
            //低音を流して振動で掛かったことを伝える。
            print("＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋魚が掛かった＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋")
            //ここで魚の情報が決定する。
            self.Fishrarity = Int(self.WaitTime)+self.Fishrarity//0~20段階評価
            self.Fishrarity /= 2
            switch self.Fishrarity{
            case 0..<4:
                print("レア度\(self.Fishrarity)の魚がhit!")
                break
            case 4..<8:
                print("レア度\(self.Fishrarity)の魚がhit!!")
                break
            case 8..<10:
                print("激アツ!!レア度\(self.Fishrarity)の魚がhit!!!")
                break
            case 10:
                print("大物の予感！？")
                break
            default:
                print("逃げられた...")
                //初期画面に戻す処理
                break
            }
            self.state = State.hooking//hookingに移行する
        }
    }
    
    //フッキングの判定と返す値を決定する関数
    func Hookingresult(){
            accZ = abs(accZ)//accZは負の値なので計算しやすいように正の値に変換する。
            calval = Float(gyroX + accZ)//取得した値を掛け算する
            calval /= 1.5//判定値のカウンタが10カウントを基準に測ったため
            
            switch calval {
                case 1..<10://1の判定
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
        gameStatus.HitCondition = sendval//Gamestatusに値を引き渡す。
        print(sendval)
        state = State.hookingend//sceneの切り替え
    }
    
    override func touched() {//？
        //state = .hooking
    }
    
    override func name() -> String {//？
        return "Hooking"
    }
}


class ResultSceneDummy: GameSceneBase {//Fightクラスに移行するようにする？。
    override func nextScene() -> GameScene? {
        return nil
    }
    
    override func name() -> String {
        return "result scene"
    }
}

