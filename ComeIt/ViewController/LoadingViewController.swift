//
//  LoadingViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/07.
//

import UIKit
import Gifu
import RxSwift
class LoadingViewController: UIViewController {
    let disposeBag = DisposeBag()
    var email = "등록된 이메일이 없습니다."
    var company = "등록된 소속이 없습니다."
    
    let githubController = GithubController.shared
    @IBOutlet weak var gifImageView: GIFImageView!
    let loginManager = LoginManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.animate(withGIFNamed: "Loading")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUser(loginManager.userAccessToken!) { user in
            self.loginManager.user = user
            self.githubController.fetchRepository(user.name, userAccessToken: self.loginManager.userAccessToken!) { repositories in
                self.githubController.repositories = repositories
//                self.loginManager.commitToDict()
                
                DispatchQueue.main.async {
                    self.moveToTabbar()
                }
            }
        }
    }
    
    func moveToTabbar(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startVC = storyboard.instantiateViewController(withIdentifier: "tabbarController") as! UITabBarController
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
    
    func fetchUser(_ userAccessToken: String, completion:@escaping (User) -> Void) {
        Observable.just(userAccessToken)
            .map { userAccessToken -> URLRequest  in
                let url = URL(string: "https://api.github.com/user")!
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
                      let reposPublic = object["public_repos"] as? Int,
                      let reposPrivate = object["total_private_repos"] as? Int,
                      let imageURL = object["avatar_url"] as? String else{
                          return User(imageURL: "", name: "Null", company: "Null" , email: "", reposPublic: 0, reposPrivate: 0)
                      }
                if let company = object["company"] as? String{
                    self.company = company
                }
                if let email = object["email"] as? String {
                    self.email = email
                }
                return User(imageURL: imageURL, name: name, company: self.company, email: self.email, reposPublic: reposPublic, reposPrivate: reposPrivate )
            }
            .subscribe { user in
                DispatchQueue.main.async {
                    completion(user)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}




