//
//  HomeViewCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import UIKit
import Combine

class HomeViewCoordinator: Coordinator{
    private var subscription = Set<AnyCancellable>()
    private var user: User
    private var repositories: [Repository]
    
    init(user: User, repositories: [Repository] ,identifier: UUID, navigationController: UINavigationController) {
        self.user = user
        self.repositories = repositories
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start(){
        let viewModel = HomeViewModel(user: user,repositories: repositories)
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") { coder in
            HomeViewController(viewModel: viewModel, coder: coder)
        }
        self.navigationController.pushViewController(viewController, animated: false)
    }
    
    func tabBarConnection() -> UINavigationController{
        let viewModel = HomeViewModel(user: user,repositories: repositories)
        let navigationController = UINavigationController()
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") { coder in
            HomeViewController(viewModel: viewModel, coder: coder)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }
}
