//
//  ViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa


class LoginViewController: UIViewController {
    let loginManager = LoginManager.shared //싱글톤 사용
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var githubLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        githubLoginButton.layer.borderWidth = 1
        githubLoginButton.layer.borderColor = UIColor.white.cgColor
        githubLoginButton.layer.cornerRadius = 30

        
        
    }

    @IBAction func LoginButtonTapped(_ sender: Any) {
        //firebase를 통한 로그인
        //로그인이 성공적으로 완료되었을 때 탭바로 넘어감. @escaping closure !!
        loginManager.getCredential(){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let startVC = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
            startVC.modalPresentationStyle = .overFullScreen
            startVC.modalTransitionStyle = .crossDissolve
            self.present(startVC, animated: true, completion: nil)
        }
        
       
        
    }
    
   
}
