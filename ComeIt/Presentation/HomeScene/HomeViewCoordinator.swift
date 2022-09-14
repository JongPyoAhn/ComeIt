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
    
    func tabBarConnection() -> UINavigationController{
        let viewModel = HomeViewModel(user: user,repositories: repositories)
        viewModel.profilePageRequested
            .sink {[weak self] user in
                self?.profilePageRequest(user)
            }
            .store(in: &subscription)

        let navigationController = UINavigationController()
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") { coder in
            HomeViewController(viewModel: viewModel, coder: coder)
        }
        navigationController.setViewControllers([viewController], animated: false)
        self.navigationController = navigationController
        return navigationController
    }
    
    func profilePageRequest(_ user: User){
        let identifier = UUID()
        let profileViewCoordinator = ProfileViewCoordinator(user: user, identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = profileViewCoordinator
        profileViewCoordinator.start()
    }
}
