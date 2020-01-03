//
//  MainDIsplay.swift
//  fishing_ar
//
//  Created by 松本　カズマ on 2020/01/04.
//  Copyright © 2020 赤嶺有平. All rights reserved.
//

import UIKit
import AudioToolbox

class MainDIsplay: UIViewController {
    
    var title_image = UIImage(named:"Title")!
    var clear_image = UIImage(named:"Clear")!
    
    
    @IBOutlet weak var TitleView: UIImageView!
    
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
}
