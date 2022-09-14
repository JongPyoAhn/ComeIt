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
        viewModel.addAlertPageRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.addAlertPageRequest()
            }
            .store(in: &subscription)
        
        let navigationController = UINavigationController()
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AlarmTableViewController") { coder in
            AlarmTableViewController(viewModel: viewModel, coder: coder)
        }
        
        navigationController.setViewControllers([viewController], animated: false)
        self.navigationController = navigationController
        return navigationController
    }
    
    func addAlertPageRequest(){
        let viewModel = AddAlertViewModel()
        let delegate = self.navigationController.topViewController as? AlarmTableViewController
        print("topview: \(String(describing: self.navigationController.topViewController))")
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AddAlertViewController") { coder in
            AddAlertViewController(viewModel: viewModel, delegate: delegate, coder: coder)
        }
        
        self.navigationController.present(viewController, animated: true)
    }
    
}


