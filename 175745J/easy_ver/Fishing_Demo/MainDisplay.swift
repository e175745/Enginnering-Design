//
//  MainDisplay.swift
//  Fishing_Demo
//
//  Created by 松本　カズマ on 2019/10/10.
//  Copyright © 2019 Spike. All rights reserved.
//

import UIKit
import AudioToolbox

class Main: UIViewController {
    
    @IBOutlet weak var TitleView: UIImageView!
    
    var title_image = UIImage(named:"Title")!
    var clear_image = UIImage(named:"Clear")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色設定
        view.backgroundColor=UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1)
        
        // BGM設定
        let soundUrl = Bundle.main.url(forResource: "Menu_BGM", withExtension: "mp3")
        var soundID: SystemSoundID = 5
        AudioServicesCreateSystemSoundID(soundUrl! as CFURL, &soundID)
        AudioServicesPlaySystemSoundWithCompletion(soundID) {}
        
        // タイトル画像設定
        TitleView.image = title_image
    }
    
    @IBAction func DeleteImage(_ sender: Any) {
        TitleView.image = clear_image
    }
    
    @IBAction func SetImage(_ sender: Any) {
        TitleView.image = title_image
    }
    
}
