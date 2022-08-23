//
//  AppCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/18.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator{
        
    override init(identifier: UUID = UUID(),navigationController: UINavigationController) {
        
        super.init(identifier: identifier, navigationController: navigationController)
    }

    func start() {
        let identifier = UUID()
        let splashViewCoordinator = SplashViewCoordinator(identifier: identifier, navigationController: navigationController)
        self.childCoordinators[identifier] = splashViewCoordinator
        splashViewCoordinator.start()
    }
}
