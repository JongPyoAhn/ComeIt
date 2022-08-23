//
//  LoadingCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/18.
//

import Foundation
import UIKit

//여기서 탭바로 넘어가야됨.

class LoadingViewCoordinator: Coordinator{
    
    override init(identifier: UUID, navigationController: UINavigationController) {
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func start() {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoadingViewController")
        self.navigationController.setViewControllers([viewController], animated: false)
    }
    

}
