//
//  SceneDelegate.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        
        
        self.coordinator = AppCoordinator(navigationController: navigationController)
        self.coordinator?.start()
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
//        LoginController.shared.show(in: window)
        
    }

   


}

