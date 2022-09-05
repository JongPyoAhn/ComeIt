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
//        tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
//        homeViewCoordinator = HomeViewCoordinator(user: user, repositories: repositories, identifier: identifier, navigationController: navigationController)
//        chartViewCoordinator = ChartViewCoordinator(user: user, repositories: repositories, identifier: identifier, navigationController: navigationController)
//        super.init(identifier: identifier, navigationController: navigationController)
//        var controllers: [UIViewController] = []
//        let homeViewController = homeViewCoordinator.navigationController
//        let chartViewController = chartViewCoordinator.navigationController
//        controllers.append(homeViewController)
//        controllers.append(chartViewController)
//
//        tabController.viewControllers = controllers
//        tabController.tabBar.isTranslucent = false
        
    }
    
    func start(){
        let TabBarController = setTabBarController()
        let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        scene?.window?.rootViewController = TabBarController
    }
    
    func setTabBarController() -> UITabBarController{
        let tabbarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
        
        let homeTabBarItem = UITabBarItem(title: "홈", image: nil, tag: 0)
        let alarmTabBarItem = UITabBarItem(title: "알람", image: nil, tag: 0)
        let chartTabBarItem = UITabBarItem(title: "통계", image: nil, tag: 1)
        
        let homeIdentifier = UUID()
        let homeViewCoordinator = HomeViewCoordinator(user: user, repositories: repositories, identifier: homeIdentifier, navigationController: navigationController)
        self.childCoordinators[identifier] = homeViewCoordinator
        let homeViewController = homeViewCoordinator.tabBarConnection()
        homeViewController.tabBarItem = homeTabBarItem
        
        let alarmIdentifier = UUID()
        let alarmViewCoordinator = HomeViewCoordinator(user: user, repositories: repositories, identifier: alarmIdentifier, navigationController: navigationController)
        self.childCoordinators[identifier] = alarmViewCoordinator
        let alarmViewController = alarmViewCoordinator.tabBarConnection()
        alarmViewController.tabBarItem = alarmTabBarItem
        
        let chartIdentifier = UUID()
        let chartViewCoordinator = ChartViewCoordinator(user: user, repositories: repositories, identifier: chartIdentifier, navigationController: navigationController)
        self.childCoordinators[identifier] = chartViewCoordinator
        let chartViewController = chartViewCoordinator.tabBarConnection()
        chartViewController.tabBarItem = chartTabBarItem
        
        tabbarController.viewControllers = [homeViewController, alarmViewController,chartViewController]
        
        return tabbarController
    }

}

