//
//  GithubController.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/14.
//

import UIKit
import RxSwift
class GithubController{
    static let shared = GithubController()
    var repositories: [Repository] = []
    var repositoryChartNames: [String] = []
    private init(){}
    let disposeBag = DisposeBag()
    
//    func fetchRepository(_ name: String, userAccessToken: String, completion: @escaping ([Repository])->Void){
//        Observable.just(name)
//            .map { name -> URLRequest  in
//                let url = URL(string: "https://api.github.com/users/\(name)/repos")!
//                //                print("url : \(url)")
//                var request = URLRequest(url: url)
//                request.httpMethod = "GET"
//                request.addValue("token \(userAccessToken)", forHTTPHeaderField: "Authorization")//헤더추가
//                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")//헤더추가
//                return request
//            }
//            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
//                return URLSession.shared.rx.response(request: request)
//            }
//            .filter { responds, _ in
//                return 200..<300 ~= responds.statusCode
//            }
//            .map { _, data -> [[String:Any]] in
//                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
//                      let result = json as? [[String: Any]] else {
//                          return []
//                      }
//                return result
//            }
//            .filter { result in
//                result.count > 0
//            }
//            .map { objects in
//                return objects.compactMap { dic -> Repository? in
//                    
//                    guard let id = dic["id"] as? Int,
//                          let name = dic["name"] as? String,
//                          let full_name = dic["full_name"] as? String
//                    else {return nil}
//                    if let language = dic["language"] as? String {
//                        return Repository(id: id, name: name, full_name: full_name, language: language)
//                    }else{
//                        return Repository(id: id, name: name, full_name: full_name, language: "Null")
//                    }
//                    
//                    
//                }
//            }
//            .subscribe(onNext: {repositories in
//                
//                DispatchQueue.main.async {
//                    completion(repositories)
//                }
//            })
//            .disposed(by: disposeBag)
//    }
    
    func fetchCommit(_ name: String,_ repository: String, userAccessToken: String ,completion: @escaping ([Commit])->Void){
        Observable.just(name)
            .map { name -> URLRequest  in
                let url = URL(string: "https://api.github.com/repos/\(name)/\(repository)/stats/commit_activity")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("token \(userAccessToken)", forHTTPHeaderField: "Authorization")//헤더추가
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
    
}
//    func fetchUser(_ userAccessToken: String, completion:@escaping (User) -> Void) {
//        Observable.just(userAccessToken)
//            .map { userAccessToken -> URLRequest  in
//                let url = URL(string: "https://api.github.com/user")!
//                var request = URLRequest(url: url)
//                request.httpMethod = "GET"
//                request.addValue("token \(userAccessToken)", forHTTPHeaderField: "Authorization")//헤더추가
//                request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")//헤더추가
//                return request
//            }
//            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
//                return URLSession.shared.rx.response(request: request)
//            }
//            .map { responds, data -> [String:Any] in
//                if 200..<300 ~= responds.statusCode{
//                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
//                          let result = json as? [String: Any] else {
//                        return [:]
//                    }
//                    return result
//                }else{
//                    NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
//                    return [:]
//                }
//            }
//            .filter { result in
//                result.count > 0
//            }
//            .map { object -> User in
//                guard let name = object["login"] as? String,
//                      let reposPublic = object["public_repos"] as? Int,
//                      let reposPrivate = object["total_private_repos"] as? Int,
//                      let imageURL = object["avatar_url"] as? String else{
//                          return User(imageURL: "", name: "Null", company: "Null" , email: "", reposPublic: 0, reposPrivate: 0)
//                      }
//                if let company = object["company"] as? String{
//                    self.company = company
//                }
//                if let email = object["email"] as? String {
//                    self.email = email
//                }
//                return User(imageURL: imageURL, name: name, company: self.company, email: self.email, reposPublic: reposPublic, reposPrivate: reposPrivate )
//            }
//            .subscribe { user in
//
//                DispatchQueue.main.async {
//                    completion(user)
//                }
//            }
//
//            .disposed(by: disposeBag)
//    }
