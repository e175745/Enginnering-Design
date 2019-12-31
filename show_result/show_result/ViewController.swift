//
//  ViewController.swift
//  show_result
//
//  Created by 下田英寿 on 2019/12/02.
//  Copyright © 2019 Hidekazu Shimoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textField1: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goNext(_ sender: Any) {
        
        let storyboard: UIStoryboard = self.storyboard!
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "View2")as! show_result
        
        nextView.argString = textField1.text!
        
        self.present(nextView, animated: true, completion: nil)
        
    }
    
}











