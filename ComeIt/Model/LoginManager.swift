//
//  LoginManager.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

//user와 userAccessToken을 싱글톤으로 사용할 때 !써주는 이유는 만약 로그아웃된 상태라서 nil값이 들어있다면 SceneDelegate의 LoginController의 노티피케이션이 감지하고 로그인페이지로 넘겨버리기때문에 무조건 값이 들어있음.
class LoginManager{
    static let shared = LoginManager() //싱글톤
    private init() {}
    //파이어베이스
    let firebaseAuth = Auth.auth()
    var provider = OAuthProvider(providerID: "github.com")
    var user: User?
    var userAccessToken: String?

    func getCredential(){
        
        provider.scopes = ["repo, user"] //저장소와 유저정보를 가져오겠다고 허가받기.
        provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                print("getCredential Error : \(error!.localizedDescription)")
            }
            if let credential = credential{
                self.firebaseAuth.signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("sign In Error : \(error.localizedDescription)")
                    }
                    //oAuthCredential로 accessToken과 idToken을 얻을 수 있음.
                    guard let oAuthCredential = authResult?.credential as? OAuthCredential else {return}
                    
                    if let userAccessToken = oAuthCredential.accessToken {
                        self.userAccessToken = userAccessToken
                        UserDefaults.standard.set(userAccessToken, forKey: "userAccessToken")
                    }
                    NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
                }
                
            }
        }
        
    }
    func logout(){
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        UserDefaults.standard.removeObject(forKey: "userAccessToken")
    }
    
    
    
//    func autoLogin(completion: @escaping ()-> Void){
//        if let userAccessToken =  UserDefaults.standard.string(forKey: "userAccessToken"){
//            self.userAccessToken = userAccessToken
//            DispatchQueue.main.async {
//                completion()
//            }
//        }else{return}
//    }
    
    
    
}


//https://firebase.google.com/docs/auth/ios/github-auth?hl=ko
//https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
//
