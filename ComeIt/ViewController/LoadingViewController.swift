//
//  LoadingViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/07.
//

import UIKit
import Gifu
import RxSwift
import Network
import FirebaseAuth
import Moya
enum AccessErr : Error{
    case tokenExpire
}

class LoadingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var email = "등록된 이메일이 없습니다."
    private var company = "등록된 소속이 없습니다."
    private let githubController = GithubController.shared
    private let networkMonitor = NetworkMonitor.shared
    private let loginManager = LoginManager.shared
    @IBOutlet weak var gifImageView: GIFImageView!
    private let user = Auth.auth().currentUser
    private var provider: MoyaProvider<GihubAPI>?
    private var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.animate(withGIFNamed: "Loading")
        let endpointClosure = { (target: GihubAPI) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            switch target {
            default:
                return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(self.loginManager.userAccessToken ?? "")"])
            }
        }
        provider = MoyaProvider<GihubAPI>(endpointClosure: endpointClosure)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !networkMonitor.isConnected{
            let disConnetedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisConnectedViewController")
            disConnetedVC.modalPresentationStyle = .fullScreen
            self.present(disConnetedVC, animated: true)
        }
        //escapingClosure써서 user정보 받아오면 진행하도록 한다.
        //그냥클로저로는 되지도않네.
        requestFetchUser(){
            self.requestFetchRepository {
                self.moveToTabbar()
            }
        }
        
        
        
//        if let userAccessToken = loginManager.userAccessToken{
//            fetchUser(userAccessToken) { user in
//                    self.loginManager.user = user
//                    self.githubController.fetchRepository(user.name, userAccessToken: self.loginManager.userAccessToken!) { repositories in
//                        self.githubController.repositories = repositories
//        //                self.loginManager.commitToDict()
//                        DispatchQueue.main.async {
//                            self.moveToTabbar()
//                        }
//                    }
//                }
//
//            }else{
//            //유저액세스토큰이 없으면 다시 받아와야하므로 로그아웃페이지로 넘어가기위해 post
//            NotificationCenter.default.post(name: .AuthStateDidChange, object: nil)
//        }
        
    }
    
}

extension LoadingViewController{
    func requestFetchUser(completion:@escaping () -> Void){
        completionHandler = completion
        provider?.request(.fetchUser){ result in
            switch result{
            case let .success(response):
                print(response)
                self.tokenValidate(response) {
                    do{
                        let decoder = JSONDecoder()
                        let data = try decoder.decode(User.self, from: response.data)
                        self.loginManager.user = data
                        completion() //escapingClosure
                    }catch let error{
                        print("에러 : \(error.localizedDescription)")
                    }
                }
            case let .failure(error):
                print("에러 : \(error.localizedDescription)")
            }
        }
    }
    func requestFetchRepository(completion:@escaping ()->Void){
        guard let userName = loginManager.user?.name else{return}
        provider?.request(.fetchRepository(userName)){ result in
            switch result{
            case let .success(response):
                do{
                    let decoder = JSONDecoder()
                    //데이터가 유실되었다 = 내가 model을 잘못만들었다.
                    //올바른 포맷이 아니기 때문에 해당 데이터를 읽을 수 없습니다 = 받아오는게 잘못됨(여기)
                    let data = try decoder.decode([Repository].self, from: response.data)
//                    print(data)
                    self.githubController.repositories = data

                    completion()
                    
                }catch let err{
                    print("레포지토리 파싱에러 : \(err.localizedDescription)")
                }
            case let .failure(error):
                print("레포지토리 에러 : \(error.localizedDescription)")
            }
            
            
        }
    }
    func tokenValidate(_ response: Response, success:(()->())){
        if 200..<300 ~= response.statusCode{
            success()
        }else if response.statusCode == 401 || response.statusCode == 403{//토큰관련 에러
            loginManager.logout()
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
}

//escapingClosure : https://dongminyoon.tistory.com/1
