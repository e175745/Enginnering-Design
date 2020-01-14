//
//  ResultViewController.swift
//  fishing_ar
//
//  Created by 下田英寿 on 2020/01/14.
//  Copyright © 2020 赤嶺有平. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController{

    @IBOutlet weak var HighScoreLabel: UILabel!
    
    @IBOutlet weak var FishSizeLabel: UILabel!
    
    //userDefaultsの定義
    let userDefaults = UserDefaults.standard
    
    let HIGHSCOREKEY = "highscore"
    let RANKKEY = "rank"
    
    var gameStatus: GameStatus!
    
    var HighScore:Double = 0
    //var RANK = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.register(defaults: [HIGHSCOREKEY:0])
        HighScore = Double(userDefaults.integer(forKey: HIGHSCOREKEY))
        
        FishSizeLabel.text = String(round(gameStatus.FishSize*100)/100)
        if(round(gameStatus.FishSize*100)/100 > HighScore){
            userDefaults.set(round(gameStatus.FishSize*100)/100, forKey: HIGHSCOREKEY)
            userDefaults.synchronize()
            HighScore = round(gameStatus.FishSize*100)/100
        }
        
        HighScoreLabel.text = HighScore.description
        
        //userDefaults.set(RANK, forKey: RANKKEY)
        //userDefaults.synchronize()
        var getRANK: [Double] = userDefaults.array(forKey: RANKKEY) as! [Double]
        getRANK.append(round(gameStatus.FishSize*100)/100)
        getRANK.sort(by: >)
        if(getRANK.count > 5){
            getRANK.removeLast()
        }
        userDefaults.set(getRANK, forKey: RANKKEY)
        userDefaults.synchronize()
        
    }
    
    @IBAction func goMainDisplay(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "MainDisplay")as! MainDIsplay
        
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func goRankView(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "RankView")as! RankViewController
        
        self.present(nextView, animated: true, completion: nil)
        
    }
}
