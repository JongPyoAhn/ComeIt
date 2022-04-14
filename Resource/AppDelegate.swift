//
//  AppDelegate.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import NotificationCenter
import UserNotifications
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    // Portrait모드로 고정
    var orientationLock = UIInterfaceOrientationMask.portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        
        //사용자승인 받기위함.
        let authorizationOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotificationCenter.requestAuthorization(options: authorizationOptions) { _ , error in
            if let error = error {
                print("Error: notification authorization request \(error.localizedDescription)")
            }
        }
        //네트워크변화상태체크하기위한 싱글톤
        NetworkMonitor.shared.startMonitoring()
        
        // Override point for customization after application launch.
        return true
    }

    


}

extension AppDelegate {
    //노티피케이션 센터를 보내기전에 어떠한 핸들링을 해줄것인지.
    //banner, list, badge, sound
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
}
