//
//  ViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var githubLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        githubLoginButton.layer.borderWidth = 1
        githubLoginButton.layer.borderColor = UIColor.white.cgColor
        githubLoginButton.layer.cornerRadius = 30
    }

    @IBAction func LoginButtonTapped(_ sender: Any) {
        
        
    }
    
}
