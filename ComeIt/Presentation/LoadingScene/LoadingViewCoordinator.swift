//
//  LoadingCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/18.
//

import Foundation
import UIKit
import Combine

class LoadingViewCoordinator: Coordinator{
    private var subscription = Set<AnyCancellable>()
    
    override init(identifier: UUID, navigationController: UINavigationController) {
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start() {
        let viewModel = LoadingViewModel()
        
        viewModel.loginPageRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.loginPageRequest()
            }
            .store(in: &subscription)
        
        viewModel.tabbarPageRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] user, repositories in
                self?.TabBarPageRequest(user, repositories)
            }
            .store(in: &subscription)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoadingViewController") { coder in
            LoadingViewController(viewModel: viewModel, coder: coder)
        }
        self.navigationController.setViewControllers([viewController], animated: false)
    }
    
    private func TabBarPageRequest(_ user: User, _ repositories: [Repository]){
        let identifier = UUID()
        let tabbarViewCoordinator = TabBarViewCoordinator(user: user, repositories: repositories, identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = tabbarViewCoordinator
        tabbarViewCoordinator.start()
    }
    
    private func loginPageRequest(){
        let identifier = UUID()
        let loginViewCoordinator = LoginViewCoordinator(identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = loginViewCoordinator
        loginViewCoordinator.start()
    }
    
}
