//
//  AlarmViewCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/09/11.
//

import Foundation
import UIKit
import Combine

class AlarmViewCoordinator: Coordinator{
    private var subscription = Set<AnyCancellable>()
    
    override init(identifier: UUID, navigationController: UINavigationController) {
        super.init(identifier: identifier, navigationController: navigationController)
    }
    
    func tabBarConnection() -> UINavigationController{
        let viewModel = AlarmViewModel()
        viewModel.addAlertSceneRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.addAlertSceneRequest()
            }
            .store(in: &subscription)
        
        let navigationController = UINavigationController()
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AlarmTableViewController") { coder in
            AlarmTableViewController(viewModel: viewModel, coder: coder)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
        return navigationController
    }
    
    func addAlertSceneRequest(){
        
    }
}
