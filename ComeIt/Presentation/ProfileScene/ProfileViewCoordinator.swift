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
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController") { coder in
            ProfileViewController(viewModel: viewModel, coder: coder)
        }
        self.navigationController.present(viewController, animated: true)
    }
}

