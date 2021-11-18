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
import simd

class LoginManager{
    static let shared = LoginManager() //싱글톤
    private init() {}
    //파이어베이스
    let firebaseAuth = Auth.auth()
    let provider = OAuthProvider(providerID: "github.com")
//    let repositoryInformation = BehaviorSubject<[Repository]>(value: [])
    var user = User(imageURL: "", name: "Null", company: "Null" , email: "", reposPublic: 0, reposPrivate: 0)
    var repositories: [Repository] = []
    private var userAccessToken: String?
    let disposeBag = DisposeBag()
    var email = "등록된 이메일이 없습니다."
    var repoTotal: [String:Int] = [:]
    var repositoryChartNames: [String] = []
    
    func getCredential(completion: @escaping () -> Void){
        
        print("getCredential")
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

                    if let userAccessToken = oAuthCredential.accessToken {
                        self.userAccessToken = userAccessToken
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
            }
        }
    }

}
    
    func fetchUser(completion:@escaping (User) -> Void) {
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
                print("==========================\(object)")
                guard let name = object["login"] as? String,
                      let company = object["company"] as? String,
                      let reposPublic = object["public_repos"] as? Int,
                      let reposPrivate = object["total_private_repos"] as? Int,
                      let imageURL = object["avatar_url"] as? String else{
                          return User(imageURL: "", name: "Null", company: "Null" , email: "", reposPublic: 0, reposPrivate: 0)
                      }
                if let email = object["email"] as? String {
                    self.email = email
                }
                return User(imageURL: imageURL, name: name, company: company, email: self.email, reposPublic: reposPublic, reposPrivate: reposPrivate )
            }
            .subscribe { user in
//                self?.userInformation.onNext(user)
                DispatchQueue.main.async {
                    completion(user)
                }
            }
            .disposed(by: disposeBag)
        
        }
        
    func fetchRepository(_ name: String,  completion: @escaping ([Repository])->Void){
        Observable.just(name)
            .map { name -> URLRequest  in
                let url = URL(string: "https://api.github.com/users/\(name)/repos")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("token \(self.userAccessToken!)", forHTTPHeaderField: "Authorization")//헤더추가
                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")//헤더추가
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { responds, _ in
                return 200..<300 ~= responds.statusCode
            }
            .map { _, data -> [[String:Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]] else {
                          return []
                      }
                return result
            }
            .filter { result in
                result.count > 0
            }
            .map { objects in
                return objects.compactMap { dic -> Repository? in
                    
                    guard let id = dic["id"] as? Int,
                          let name = dic["name"] as? String,
                          let full_name = dic["full_name"] as? String
                          else {return nil}
                    
                    return Repository(id: id, name: name, full_name: full_name)
                }
            }
            .subscribe(onNext: {repositories in
               
                DispatchQueue.main.async {
                    completion(repositories)
                }
            })
            .disposed(by: disposeBag)
        
        
        
    
    }

    func fetchCommit(_ name: String,_ repository: String ,completion: @escaping ([Commit])->Void){
        Observable.just(name)
            .map { name -> URLRequest  in
                let url = URL(string: "https://api.github.com/repos/\(name)/\(repository)/stats/commit_activity")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("token \(self.userAccessToken!)", forHTTPHeaderField: "Authorization")//헤더추가
                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")//헤더추가
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { responds, _ in
                return 200..<300 ~= responds.statusCode
            }
            .map { _, data -> [[String:Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]] else {
                          return []
                      }
                return result
            }
            .filter { result in
                result.count > 0
            }
            .map { objects in
                return objects.compactMap { dic -> Commit? in
                    
                    guard let week = dic["week"] as? Int,
                          let days = dic["days"] as? [Int],
                          let total = dic["total"] as? Int
                    else{ return nil}
                    
                    return Commit(week: week, days: days, total: total)
                }
            }
            .subscribe(onNext: {commits in
               
                DispatchQueue.main.async {
                    completion(commits)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func commitToDict(){
        for i in self.repositories{
            self.fetchCommit(self.user.name, i.name) { commits in
                let latestCommit = commits.last!
                self.repoTotal[i.name] = latestCommit.total
            }
        }
    }
}


//https://firebase.google.com/docs/auth/ios/github-auth?hl=ko
//https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
//
