//
//  HookingScene.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 仲西智章. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class HookingScene: GameSceneBase {
    var audioPlayer: AVAudioPlayer!
    var HookAcc = SCNVector3(0,0,0)
    var HookGyro = SCNVector3(0,0,0)
    var gyroX:Float = 0
    var accZ:Float = 0
    var seccount:Float = 0
    var WaitTime = Double.random(in: 1 ... 10)// ランダムな1から10を生成->待ち時間
    var Fishrarity = Int.random(in: 1 ... 10)//魚のレア度をランダムに決定
    var fishleave = Int.random(in:0 ... 60)
    var calval:Float = 0
    var sendval:Int = 0
    var waitend:Bool = false
    
    enum State {//処理のグループ分け
        case waiting
        case hooking
        case hookingend
        case hookingfalse
    }
    
    let stateDesc: [State:String] = [
        .waiting:"waiting",
        .hooking:"hooking",
        .hookingend:"hookingend",
        .hookingfalse:"hookingfalse"
    ]
    
    var state = State.waiting
    
    override func update(acc:SCNVector3,gyro:SCNVector3){
        HookAcc = acc//using HookAcc.Z
        HookGyro = gyro//using HookGyro.X
        switch self.state{
            case .hookingfalse:
                //ここにHooking失敗の処理
                print("false")
                break
            case .waiting:
                if(waitend != true){
                    self.waittimer()
                }
                break
            case .hooking:
//画面上の動き(acc.z)が上向き(-Z方向),画面の回転(gyro.x)が手前側(+X方向)の時に値を取得する。
                if(seccount < 15){//intervalseconds(1F)*15 = 0.5秒
                    if (HookGyro.x >= 0 && HookAcc.z <= 0){
                        gyroX += HookGyro.x
                        accZ += HookAcc.z
                        seccount += 1
//                        print("+++++++ gyroX=\(gyroX) +++++++")
//                        print("+++++++ accZ=\(accZ) +++++++")
                    } else if (HookGyro.x < 0 && HookAcc.z <= 0){
                        //accZのみが正しい値の場合
                        accZ += HookAcc.z
                        seccount += 1
//                        print("+++++++ accZ=\(accZ) +++++++")
                    } else if (HookGyro.x >= 0 && HookAcc.z > 0){
                        //gyroXが正しい値の場合
                        gyroX += HookGyro.x
                        seccount += 1
//                        print("+++++++ gyroX=\(gyroX) +++++++")
                    } else {
                        //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                        //(動かしていない場合、処理が終わらないことを防ぐ為)
                        seccount += 0.5
//                        print("+++++++++++ miss +++++++++++")
                    }
                }else if (seccount >= 15){//終了時(0.5秒後)にHookingresultを呼び出す
                    self.Hookingresult()
                    break
                }else{
//                    print("Hookingクラスのseccountが正しい動作をしていません")
                    break
            }
        case .hookingend:
            break
        }
    }
    
    func waittimer(){
        waitend = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTime) {
            //Vizualizerにウキをどのくらい沈めたいか
            self.visualizer.moveFloat(to: SCNVector3(self.visualizer.floatObject!.position.x,-0.1,self.visualizer.floatObject!.position.z))
            
            // mp3音声(音声の名前.mp3)の再生。音を流して掛かったことを伝える。
            self.visualizer.playSound(name: "MGS_!")
            self.visualizer.showImage(name:"exclamation.png",position:CGPoint(x:500,y:750),size:CGSize(width:200,height:200),showTime:1)
            
//            print("＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋魚が掛かった＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋")
            //ここで魚の情報が決定する。
//            print("WaitTime=\(self.WaitTime),Fishrarity=\(self.Fishrarity)")
            self.Fishrarity = Int(round(self.WaitTime)) + self.Fishrarity//0~100段階評価
            self.Fishrarity /= 2
            self.gameStatus.FishRarity = self.Fishrarity
//print("gameStatusのFishRarityが\(self.gameStatus.FishRarity)に更新されました。")
            switch self.Fishrarity{
            case 1..<4://1~3
                print("hit?")
                self.state = State.hooking//hookingに移行する
                break
            case 4..<7://4~6
                print("hit!")
                self.state = State.hooking
                break
            case 7..<10://7~9
                print("大物の予感！？")
                self.state = State.hooking
                break
            case 10://10
                print("激アツ!!!")
                self.state = State.hooking
                break
            default:
                print("逃げられた...")
                self.state = State.hookingfalse//初期画面に戻す処理
                break
            }
        }
    }
    
    //フッキングの判定と返す値を決定する関数
    func Hookingresult(){
            accZ = abs(accZ)//accZは負の値なので計算しやすいように正の値に変換する。
            calval = Float(gyroX * accZ)//取得した値を掛け算する
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
                case 150..<500://10の判定
                    sendval = 10
                    break
                default://0(動かしていない時)や、予期せぬ値
                    sendval = 0
                    break
            }
        self.Fishrarity = 10 - self.Fishrarity
        self.Fishrarity *= sendval
//        print("計算後の判定値は\(Fishrarity)です。")
        if(Fishrarity < fishleave){
//            print("+++++++++++++++++失敗+++++++++++++++++++++")
//            print("HitConditionが\(gameStatus.HitCondition)に更新されました。")
            self.state = State.hookingfalse
        }else{
//            print("+++++++++++++++++成功+++++++++++++++++++++")
            self.gameStatus.HitCondition = sendval//Gamestatusに値を引き渡す。
//            print("gameStatusのHitConditionが\(gameStatus.HitCondition)に更新されました。")
            self.state = State.hookingend//sceneの切り替え
        }
    }
    override func touched() {//？
        //state = .hooking
    }
    
//    override func name() -> String {//？
//        return "Hooking"
//    }
    
    override func name() -> String {
        return "Hooking("+stateDesc[state]!+")"
    }
    
    override func nextScene() -> GameScene? {
        if(state == .hookingend){
            
            return FightingScene(base: self)
            
        }else if(state == .hookingfalse){
            
            return BackScene(base: self)
            
        }else{
            return nil
        }
    }
}
