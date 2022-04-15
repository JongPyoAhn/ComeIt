//
//  LoginController.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/14.
//

import UIKit
import FirebaseAuth
class LoginController{
    static let shared = LoginController()
    let loginManager = LoginManager.shared
    private var window: UIWindow!
    private var rootViewController: UIViewController?{
        didSet{//didSet은 프로퍼티의 값이 변경되기 직전을 감지하는것입니다.
            window.rootViewController = rootViewController
        }
    }
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(checkSignIn), name: .AuthStateDidChange, object: nil)
    }
    
    func show(in window: UIWindow?){
        guard let window = window else {
            fatalError("cannot layout app with a nil window")
        }
        self.window = window
        window.tintColor = .systemBlue
        window.backgroundColor = .systemBackground
        checkSignIn()
        //가장 앞쪽에 배치되는 키 윈도우로 설정한다.
        window.makeKeyAndVisible()
    }
    @objc private func checkSignIn(){
        if let _ = Auth.auth().currentUser, let userAccessToken = UserDefaults.standard.string(forKey: "userAccessToken"){
            loginManager.userAccessToken = userAccessToken
            setHomeScene()
        }else{
            setLoginScene()
        }
    }
    private func setHomeScene(){
        let loadingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingViewController")
        rootViewController = loadingVC
    }
    
    private func setLoginScene(){
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        rootViewController = loginVC
    }
    
}
