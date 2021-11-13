//
//  LoadingViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/07.
//

import UIKit
import Gifu
class LoadingViewController: UIViewController {
    @IBOutlet weak var gifImageView: GIFImageView!
    let loginManager = LoginManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.animate(withGIFNamed: "alarmgif")
        
        
        //로그인한 유저정보 미리 가져오기.
        loginManager.fetchUser { user in
            self.loginManager.user = user
            //
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let startVC = storyboard.instantiateViewController(withIdentifier: "tabbarController") as! UITabBarController
            startVC.modalPresentationStyle = .overFullScreen
            startVC.modalTransitionStyle = .crossDissolve
            self.present(startVC, animated: true, completion: nil)
            
        }


        
    }
    


}
