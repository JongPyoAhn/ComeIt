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

class LoginManager{
    static let shared = LoginManager() //싱글톤
    private init() {}
    let firebaseAuth = Auth.auth()
    let provider = OAuthProvider(providerID: "github.com")
    private let userInformation = PublishSubject<User>() //방출받을게 1밖에없어서 Publish
    private var userAccessToken: String?
    let disposeBag = DisposeBag()
    
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
                    //oAuthCredentila로 accessToken과 idToken을 얻을 수 있음.
                    guard let oAuthCredential = authResult?.credential as? OAuthCredential else {return}
                    self.userAccessToken = oAuthCredential.accessToken!
                    self.fetchUser()
                    self.userInformation
                        .subscribe(onNext:{
                            print($0)
                        })
                    }
            }
        }
    }
    
    func fetchUser() {
        /*객체 하나만 받아오면됨.
        유저액세스토큰을 map으로 가공해서 전달할거임.
        옵저버블.just(1)이 있으면 1을 onNext로 나한테 방출하는 거임.
        여기선 userAcessToken을 이용해서 여러형태로 변환하고 파싱해서 마지막에
        userInformation = PublishSubject<User>()에 onNext로 방출해준거임.
         */
        Observable.just(userAccessToken)
            .map { userAccessToken -> URLRequest  in
                let url = URL(string: "https://api.github.com/user")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("token \(userAccessToken!)", forHTTPHeaderField: "Authorization")//헤더추가
                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")//헤더추가
//                print(request)
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { responds, _ in
                return 200..<300 ~= responds.statusCode
            }
            .map { _, data -> [String:Any] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [String: Any] else {
                          return [:]
                      }
                return result
            }
            .filter { result in
                result.count > 0
            }
            .map { object -> User in
                guard let name = object["login"] as? String,
                      let company = object["company"] as? String,
                      let reposPublic = object["public_repos"] as? Int,
                      let reposPrivate = object["total_private_repos"] as? Int else {
                          return User(name: "null", company: "null", reposPublic: 0, reposPrivate: 0)
                      }
                return User(name: name, company: company, reposPublic: reposPublic, reposPrivate: reposPrivate)
            }
            .subscribe { userInformation in
                self.userInformation.onNext(userInformation)
                
            }
            .disposed(by: disposeBag)
    }

    
    
    
    
    
}




//https://firebase.google.com/docs/auth/ios/github-auth?hl=ko
//https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
//
