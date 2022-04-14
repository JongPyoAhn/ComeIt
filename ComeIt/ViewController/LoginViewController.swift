//
//  ViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    let loginManager = LoginManager.shared //싱글톤 사용
   
    let firebaseAuth = Auth.auth()
    @IBOutlet weak var githubLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        githubLoginButton.layer.borderWidth = 3
        githubLoginButton.layer.borderColor = UIColor.black.cgColor
        githubLoginButton.layer.cornerRadius = 25
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        //firebase를 통한 로그인
        loginManager.getCredential()
    }
}
