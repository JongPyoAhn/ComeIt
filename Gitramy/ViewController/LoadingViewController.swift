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
    @IBOutlet weak var gifImageView: GIFImageView!
    let loginManager = LoginManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.animate(withGIFNamed: "Loading")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !NetworkMonitor.shared.isConnected{
            moveDisConnected()
        }else{
            //로그인한 유저정보 미리 가져오기.
            loginManager.fetchUser { user in
                self.loginManager.user = user
                print("userName : \(user.name)")
                print("userName : \(user.name)")
                self.loginManager.fetchRepository(user.name) { repositories in
                    self.loginManager.repositories = repositories
                    print("==\(self.loginManager.repositories)")
                    self.loginManager.commitToDict()
                
                    DispatchQueue.main.async {
                        self.moveToTabbar()
                    }

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
}




