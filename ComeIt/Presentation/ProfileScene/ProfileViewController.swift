//
//  profileViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/12.
//

import UIKit
import FirebaseAuth
import Firebase
class ProfileViewController: UIViewController {
    private let user = FirebaseAPI.shared.user!
    private let firebaseAuth = Auth.auth()
    
    @IBOutlet weak var repositoriesLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: user.imageURL) else {return}
        let data = try? Data(contentsOf: url)
        DispatchQueue.main.async {
            self.profileImage.image = UIImage(data: data!)
        }
        profileImage.contentMode = .scaleAspectFit
        nameLabel.text = user.name
        
        emailLabel.text = user.email
        companyLabel.text = "소속 : \(user.company)"
        repositoriesLabel.text = "총 레포지토리 수 : \(user.reposPublic + user.reposPrivate)"
    }
    
    
    @IBAction func moveToRepositoryButtonTapped(_ sender: Any) {
        if let url = URL(string: "https://github.com/\(self.user)?tab=repositories"){
            UIApplication.shared.open(url, options: [:])
        }
        
    }
    
//    @IBAction func logoutButtonTapped(_ sender: Any) {
//        //자동로그인방지
//        print("로그아웃 버튼 눌림")
//        loginManager.logout()
//        self.dismiss(animated: true)
//    }
}
