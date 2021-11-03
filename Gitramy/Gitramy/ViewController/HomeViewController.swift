//
//  HomeViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit



class HomeViewController: UIViewController {
    
    @IBOutlet weak var numOfRepository: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelImage: UIImageView!
    let loginManager = LoginManager.shared
    var userName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.levelImage.image = UIImage(named: "브론즈_2")
        //
        loginManager.fetchUser {[weak self] user in
            guard let self = self else {return}
            
            self.nameLabel.text = "\(user.name)님 환영합니다."
            self.companyLabel.text = "소속 : \(user.company)"
            self.numOfRepository.text = "총 레포지토리 수 : \(user.reposPublic + user.reposPrivate)"
            self.loginManager.fetchRepository(user.name) { repositories in
                
            }
        }
        //
        
    }
    
    

}


extension HomeViewController {
    
    
}
