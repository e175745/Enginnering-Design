//
//  rank.swift
//  show_result
//
//  Created by 下田英寿 on 2019/12/24.
//  Copyright © 2019 Hidekazu Shimoda. All rights reserved.
//

import UIKit

class rank: UIViewController {
        
    @IBOutlet weak var Rank: UILabel!
    
    let defaults = UserDefaults.standard
    
    //var getrank: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //defaults.integer(forKey: "rank")
        
        let getrank: [Int] = defaults.array(forKey: "rank") as! [Int]
        
        //rank.text = String(defaults.integer(forKey: "rank"))
        
        Rank.text = String(describing: getrank)
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func goHome(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "View1")as! ViewController
        
        self.present(nextView, animated: true, completion: nil)
        
    }
    
    
    
    
    
}
