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
    
    @IBOutlet weak var FishNameLabel: UILabel!
    
    //userDefaultsの定義
    let userDefaults = UserDefaults.standard
    
    let HIGHSCOREKEY = "highscore"
    let RANKKEY = "rank"
    
    var gameStatus: GameStatus!
    
    var HighScore:Int = 0
    //var RANK = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefaults.register(defaults: [HIGHSCOREKEY:0])
        HighScore = (userDefaults.integer(forKey: HIGHSCOREKEY))
        
        FishSizeLabel.text = String(Int(gameStatus.FishSize))
        if(Int(gameStatus.FishSize) > HighScore){
            userDefaults.set(gameStatus.FishSize, forKey: HIGHSCOREKEY)
            userDefaults.synchronize()
            HighScore = Int(gameStatus.FishSize)
        }
        
        HighScoreLabel.text = HighScore.description
        
        FishNameLabel.text = gameStatus.FishName
        
        /*
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
        */
        
    }
    
    @IBAction func goMainDisplay(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "MainDisplay")as! MainDIsplay
        
        self.present(nextView, animated: true, completion: nil)
    }
    
    /*
    @IBAction func goRankView(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "RankView")as! RankViewController
        
        self.present(nextView, animated: true, completion: nil)
        
    }
    */
}
