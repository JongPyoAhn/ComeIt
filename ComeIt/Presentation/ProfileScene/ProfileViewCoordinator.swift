//
//  ProfileViewCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/09/06.
//

import Foundation
import Combine
import UIKit

class ProfileViewCoordinator: Coordinator {
    private var subscription = Set<AnyCancellable>()
    private var user: User
    init(user: User ,identifier: UUID, navigationController: UINavigationController) {
        self.user = user
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start(){
        let viewModel = ProfileViewModel(user: user)
        
        viewModel.popViewRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.popViewController()
            }
            .store(in: &subscription)
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") { coder in
            ProfileViewController(viewModel: viewModel, coder: coder)
        }
        viewController.modalTransitionStyle = .partialCurl
        self.navigationController.pushViewController(viewController, animated: false)
    }
    
    func popViewController(){
        self.navigationController.popViewController(animated: false)
    }
    
    
}

