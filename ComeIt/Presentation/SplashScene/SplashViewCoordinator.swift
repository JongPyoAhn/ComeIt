//
//  SplashCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/19.
//

import Foundation
import Combine
import UIKit

class SplashViewCoordinator: Coordinator{
    private var subscription = Set<AnyCancellable>()

    override init(identifier: UUID,navigationController: UINavigationController){
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start() {
        let viewModel = SplashViewModel()
        
        viewModel.loginPageRequested
            .receive(on: DispatchQueue.main)
            .print()
            .sink {[weak self] _ in
                self?.loginPageRequest()
            }
            .store(in: &subscription)
        
        viewModel.loadingPageRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.loadingPageRequest()
            }.store(in: &subscription)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SplashViewController") { coder in
            SplashViewController(viewModel: viewModel, coder: coder)
        }

        self.navigationController.pushViewController(viewController, animated: false)
    }
    
    private func loginPageRequest(){
        let identifier = UUID()
        let loginViewCoordinator = LoginViewCoordinator(identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = loginViewCoordinator
        loginViewCoordinator.start()
    }
    
    private func loadingPageRequest(){
        let identifier = UUID()
        let loadingViewCoordinator = LoadingViewCoordinator(identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = loadingViewCoordinator
        loadingViewCoordinator.start()
    }
}
