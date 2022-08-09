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

class LoadingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private var email = "등록된 이메일이 없습니다."
    private var company = "등록된 소속이 없습니다."
    private let githubController = GithubController.shared
    private let networkMonitor = NetworkMonitor.shared
    private let loginManager = LoginManager.shared
    @IBOutlet weak var gifImageView: GIFImageView!
    private let user = Auth.auth().currentUser
    private var provider: MoyaProvider<GithubAPI>?
    private var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.animate(withGIFNamed: "Loading")
        let endpointClosure = { (target: GithubAPI) -> Endpoint in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            switch target {
            default:
                return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(self.loginManager.userAccessToken ?? "")"])
            }
        }
        provider = MoyaProvider<GithubAPI>(endpointClosure: endpointClosure)
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
        guard let provider = provider else {return}
        
        self.githubController.requestFetchUser(provider){
            guard let userName = self.loginManager.user?.name else {return}
            self.githubController.requestFetchRepository(provider, userName){
                self.moveToTabbar()
            }
        }
    }
}

extension LoadingViewController{
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
