//
//  MainDIsplay.swift
//  fishing_ar
//
//  Created by 松本　カズマ on 2020/01/04.
//  Copyright © 2020 赤嶺有平. All rights reserved.
//

import UIKit
import AVFoundation

class MainDIsplay: UIViewController {
    
    var title_image = UIImage(named:"Title")!
    var clear_image = UIImage(named:"Clear")!
    var audioPlayer: AVAudioPlayer!
    
    
    @IBOutlet weak var TitleView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色設定
        view.backgroundColor=UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1)
        
        // BGM設定
        self.playSound(name: "kibun issin3")
        
        
        // タイトル画像設定
        TitleView.image = title_image
    }
    
    @IBAction func goRank(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "RankView")as! RankViewController
        
        self.present(nextView, animated: true, completion: nil)
        
    }
    
    
}

extension MainDIsplay: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }

        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))

            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self

            // 音声の再生
            audioPlayer.play()
        } catch {
        }
    }
}
