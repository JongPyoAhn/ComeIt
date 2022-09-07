//
//  ViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import Combine
import CombineCocoa

protocol LoginViewControllerDelegate{
    func loginDelegate()
}

class LoginViewController: UIViewController {
    @IBOutlet weak var githubLoginButton: UIButton!
    private var viewModel: LoginViewModel
    private var subscription = Set<AnyCancellable>()
    
    init?(viewModel: LoginViewModel, coder: NSCoder){
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindUI()
    }
}

extension LoginViewController{
    private func configureUI(){
        githubLoginButton.layer.borderWidth = 3
        githubLoginButton.layer.borderColor = UIColor.black.cgColor
        githubLoginButton.layer.cornerRadius = 25
    }
}

extension LoginViewController{
    private func bindUI(){
        self.githubLoginButton.tapPublisher
            .sink {[weak self] _ in
                self?.viewModel.githubLoginButtonDidTap()
            }
            .store(in: &subscription)
    }
}