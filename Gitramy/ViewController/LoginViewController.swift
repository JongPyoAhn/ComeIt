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
        self.loginManager.autoLogin {
            self.moveToLoadingViewController()
        }
        
    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {
        //firebase를 통한 로그인
        //로그인이 성공적으로 완료되었을 때 탭바로 넘어감. @escaping closure !!
        if !NetworkMonitor.shared.isConnected{
            moveDisConnected()
        }else{
            loginManager.getCredential(){
                self.moveToLoadingViewController()
            }
        }
    }
    
    func moveToLoadingViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startVC = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        startVC.modalPresentationStyle = .fullScreen
        startVC.modalTransitionStyle = .crossDissolve
        self.present(startVC, animated: true, completion: nil)
    }
    
    func moveDisConnected(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let disConnectedVC = storyboard.instantiateViewController(withIdentifier: "DisConnectedViewController")
        disConnectedVC.modalPresentationStyle = .fullScreen
        disConnectedVC.modalTransitionStyle = .crossDissolve
        self.present(disConnectedVC, animated: false, completion: nil)
    }
   
}
