//
//  profileViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/12.
//

import UIKit
import Combine

import CombineCocoa
import FirebaseAuth
import Firebase
class ProfileViewController: UIViewController {
    private let firebaseAuth = Auth.auth()
    
    @IBOutlet weak var repositoriesLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var moveToRepositoryButton: UIButton!
    
    private var viewModel: ProfileViewModel
    private var subscription = Set<AnyCancellable>()
    
    init?(viewModel: ProfileViewModel,coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        configureUI()
        
    }
    
    func configureUI(){
        profileImage.contentMode = .scaleAspectFit
        
    }
    
    func bindUI(){
        self.moveToRepositoryButton.tapPublisher
            .sink { _ in
                self.viewModel.moveToRepositoryButtonDidTapped()
            }
            .store(in: &subscription)
        
        self.viewModel.getUrlImageRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] data in
                self?.profileImage.image = UIImage(data: data)
            }
            .store(in: &subscription)
        
        self.viewModel.userPublisher
            .sink {[weak self] user in
                guard let self = self else {return}
                self.nameLabel.text = user.name
                self.emailLabel.text = user.email
                self.companyLabel.text = "소속 : \(user.company)"
                self.repositoriesLabel.text = "총 레포지토리 수 : \(user.reposPublic + user.reposPrivate)"
            }
            .store(in: &subscription)
        
        self.viewModel.getUrlImage()
    }

}
