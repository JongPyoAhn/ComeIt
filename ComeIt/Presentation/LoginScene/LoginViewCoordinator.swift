//
//  LoginCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/18.
//

import Foundation
import UIKit
import Combine

class LoginViewCoordinator: Coordinator{
    var subscription = Set<AnyCancellable>()
    
    override init(identifier: UUID, navigationController: UINavigationController) {
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start() {
        let viewModel = LoginViewModel()
        
        viewModel.credentialPass
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.loadingPageRequest()
            }.store(in: &subscription)
        
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController") { coder in
            LoginViewController(viewModel: viewModel, coder: coder)
        }
        
        self.navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func loadingPageRequest(){
        let identifier = UUID()
        let loadingViewCoordinator = LoadingViewCoordinator(identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = loadingViewCoordinator
        loadingViewCoordinator.start()
    }
}
