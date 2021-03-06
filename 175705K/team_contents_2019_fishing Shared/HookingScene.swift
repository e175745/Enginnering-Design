//
//  HookingScene.swift
//  team_contents_2019_fishing
//
//  Created by Yuhei Akamine on 2019/12/14.
//  Copyright © 2019 仲西智章. All rights reserved.
//
import Foundation
import SceneKit
//本当に本当に最後かも
class HookingScene: GameSceneBase {
    var HookAcc = SCNVector3(0,0,0)
    var HookGyro = SCNVector3(0,0,0)
    var gyroX:Float = 0
    var accZ:Float = 0
    var seccount:Float = 0
    let Fishrarity = Int.random(in: 1 ... 10)//魚のレア度をランダムに決定
    var WaitTime = Double.random(in: 1 ... 10)// ランダムな1から10を生成->待ち時間
    var rarity:Int = 0
    var fishleave = Int.random(in:0 ... 10)
    var calval:Float = 0
    var sendval:Int = 0
    var waitend:Bool = false
    var fishsizeSmall = Double.random(in: 5 ... 7)
    var fishsizeNormal = Double.random(in: 5 ... 8)
    var fishsizeBig = Double.random(in: 5 ... 10)
    
    enum State {
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
        HookAcc = acc
        HookGyro = gyro
        switch self.state{
            case .hookingfalse:
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
                    } else if (HookGyro.x < 0 && HookAcc.z <= 0){
                        //accZのみが正しい値の場合
                        accZ += HookAcc.z
                        seccount += 1
                    } else if (HookGyro.x >= 0 && HookAcc.z > 0){
                        //gyroXが正しい値の場合
                        gyroX += HookGyro.x
                        seccount += 1
                    } else {
                        //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                        //(動かしていない場合、処理が終わらないことを防ぐ為)
                        seccount += 0.5
                    }
                }else if (seccount >= 15 && gyroX<1 && accZ<1){
                    self.state = .hookingfalse
                    break
                }else if (seccount >= 15){
                    self.Hookingresult()
                    break
                }else{
                    self.state = .hookingfalse
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
            self.visualizer.moveFloat(to: SCNVector3(self.visualizer.floatObject!.position.x,-0.1,self.visualizer.floatObject!.position.z))
            self.visualizer.playSound(name: "MGS_!")
            self.visualizer.showImage(name:"exclamation.png",position:CGPoint(x:500,y:750),size:CGSize(width:200,height:200),showTime:1)
            //ここで魚の情報が決定する。
            self.rarity = self.Fishrarity + Int(round(self.WaitTime))
            self.rarity /= 2
            self.gameStatus.FishRarity = Int(self.rarity)
            if(self.gameStatus.FishRarity>0){
                self.state = State.hooking
            }else{
                self.state = State.hookingfalse
            }
        }
    }
    
    //フッキングの判定と返す値を決定する関数
    func Hookingresult(){
        accZ = abs(accZ)
        calval = Float(gyroX * accZ)
        calval /= 1.5//判定値のカウンタが10カウントを基準に測ったため
        
        if(calval<200 || calval>=1){
            sendval = Int(floor(calval/20)) + 1
        }else if(calval<=500 || calval>=200){
            sendval = 10
        }else{
            sendval = 0
        }
        rarity = 10 - self.gameStatus.FishRarity
        rarity += sendval
        if(rarity < fishleave){
            //失敗
            self.state = State.hookingfalse
        }else{
            //成功
            switch self.gameStatus.FishRarity {
            case 1..<4://1~3
                self.visualizer.showImage(name:"hit.png",position:CGPoint(x:500,y:750),size:CGSize(width:400,height:400),showTime:1)
                self.gameStatus.FishSize = Double(self.gameStatus.FishRarity) * self.fishsizeSmall
                self.state = State.hookingend
                break
            case 4..<7://4~6
                self.visualizer.showImage(name:"Hit!.png",position:CGPoint(x:500,y:750),size:CGSize(width:500,height:500),showTime:1)
                self.gameStatus.FishSize = Double(self.gameStatus.FishRarity) * self.fishsizeNormal
                self.state = State.hookingend
                break
            case 7..<10://7~9
                self.visualizer.showImage(name:"big.png",position:CGPoint(x:500,y:750),size:CGSize(width:600,height:600),showTime:1)
                self.gameStatus.FishSize = Double(self.gameStatus.FishRarity) * self.fishsizeBig
                self.state = State.hookingend
                break
            case 10://10
                self.visualizer.showImage(name:"superlucky.png",position:CGPoint(x:500,y:750),size:CGSize(width:900,height:900),showTime:1)
                self.gameStatus.FishSize = Double(self.gameStatus.FishRarity) * self.fishsizeBig
                self.visualizer.playSound(name: "free_sound1063")
                self.state = State.hookingend
                break
            default:
                self.state = State.hookingfalse
            }
            self.gameStatus.HitCondition = sendval
//            print("gameStatusのHitConditionが\(gameStatus.HitCondition)に更新されました。")
        }
    }
    override func touched() {
    }
    
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
