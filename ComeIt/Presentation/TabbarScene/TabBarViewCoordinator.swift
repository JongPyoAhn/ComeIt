//
//  TabBarViewCoordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/25.
//

import Foundation

import Combine
import UIKit

class TabBarViewCoordinator: Coordinator{
    private var subscription = Set<AnyCancellable>()
//    private var user: User
//    private var repositories: [Repository]
    
    var user: User
    var repositories: [Repository]
    
    init(user: User, repositories: [Repository],identifier: UUID, navigationController: UINavigationController) {
        self.user = user
        self.repositories = repositories
        super.init(identifier: identifier, navigationController: navigationController)
        
    }
    
    func start(){
        let tabBarController = setTabBarController()
        self.navigationController.isNavigationBarHidden = true
        self.navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    func setTabBarController() -> UITabBarController{
        let tabbarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        
        let homeTabBarItem = UITabBarItem(title: "홈", image: nil, tag: 0)
        let alarmTabBarItem = UITabBarItem(title: "알람", image: nil, tag: 0)
        let chartTabBarItem = UITabBarItem(title: "통계", image: nil, tag: 1)
        
        let homeIdentifier = UUID()
        let homeViewCoordinator = HomeViewCoordinator(user: user, repositories: repositories, identifier: homeIdentifier, navigationController: navigationController)
        self.childCoordinators[homeIdentifier] = homeViewCoordinator
        let homeViewController = homeViewCoordinator.tabBarConnection()
        homeViewController.tabBarItem = homeTabBarItem
        
        let alarmIdentifier = UUID()
        let alarmViewCoordinator = AlarmViewCoordinator(identifier: alarmIdentifier, navigationController: navigationController)
        self.childCoordinators[alarmIdentifier] = alarmViewCoordinator
        let alarmViewController = alarmViewCoordinator.tabBarConnection()
        alarmViewController.tabBarItem = alarmTabBarItem
        
        let chartIdentifier = UUID()
        let chartViewCoordinator = ChartViewCoordinator(user: user, repositories: repositories, identifier: chartIdentifier, navigationController: navigationController)
        self.childCoordinators[chartIdentifier] = chartViewCoordinator
        let chartViewController = chartViewCoordinator.tabBarConnection()
        chartViewController.tabBarItem = chartTabBarItem
        
        tabbarController.viewControllers = [homeViewController, alarmViewController,chartViewController]
        
        return tabbarController
    }

}

