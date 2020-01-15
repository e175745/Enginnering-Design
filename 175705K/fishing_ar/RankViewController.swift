//
//  RankViewController.swift
//  fishing_ar
//
//  Created by 下田英寿 on 2020/01/14.
//  Copyright © 2020 赤嶺有平. All rights reserved.
//

import UIKit

class RankViewController: UIViewController {
    
    @IBOutlet weak var RankLabel1: UILabel!
    
    @IBOutlet weak var RankLabel2: UILabel!
    
    @IBOutlet weak var RankLabel3: UILabel!
    
    @IBOutlet weak var RankLabel4: UILabel!
    
    @IBOutlet weak var RankLabel5: UILabel!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let Ranking: [Double] = userDefaults.array(forKey: "rank") as! [Double]
        
        RankLabel1.text = Ranking.description
        RankLabel2.text = Ranking[1].description
        RankLabel3.text = Ranking[2].description
        RankLabel4.text = Ranking[3].description
        RankLabel5.text = Ranking[4].description
    }
    
    @IBAction func goMainDisplay(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
               
        let nextView = storyboard.instantiateViewController(withIdentifier: "MainDisplay")as! MainDIsplay
               
        self.present(nextView, animated: true, completion: nil)
               
    }
    
}
