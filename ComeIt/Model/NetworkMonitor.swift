//
//  NetworkMonitor.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/24.
//
import UIKit
import Foundation
import Network
import SwiftUI
import RxSwift

final class NetworkMonitor{
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor: NWPathMonitor
    public private(set) var isConnected:Bool = false
    public private(set) var connectionType:ConnectionType = .unknown
    
    
    /// 연결타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init(){
        print("init 호출")
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring(){
        print("startMonitoring 호출")
        print("===========================is Conneted : \(isConnected)")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            print("path :\(path)")
            
            self?.isConnected = path.status == .satisfied
            self?.getConenctionType(path)
            
            if self?.isConnected == true{
                print("연결이된 상태임!")
                
            }else{
                print("연결 안된 상태임!")
                
            }
        }
    }

    
    public func stopMonitoring(){
        print("stopMonitoring 호출")
        monitor.cancel()
    }
    
    
    private func getConenctionType(_ path:NWPath) {
        print("getConenctionType 호출")
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
            print("wifi에 연결")

        }else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("cellular에 연결")

        }else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("wiredEthernet에 연결")

        }else {
            connectionType = .unknown
            print("unknown ..")
        }
    }
    
//    func moveDisConnectedViewController(){
//
//
//        DispatchQueue.main.async {
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let startVC = storyboard.instantiateViewController(withIdentifier: "DisConnectedViewController")
//            startVC.modalPresentationStyle = .overFullScreen
//            startVC.modalTransitionStyle = .crossDissolve
//            self.currentVC.present(startVC, animated: false, completion: nil)
//        }
//
//    }
//    func getCurrentVC(){
//        //지금문제 : 데이터 한번 껏다 킬때는 되는데 다시 끄면 currentVC가 게속 DisConnectViewController임.
//        //내생각엔 이함수를 뜯어교쳐야할듯.
//        //getCurrentVC가 print가 안되고있는걸봐선 이미 값이있어서 다시 안들어가는거같은데..
//            if let currentVC = UIApplication.topViewController(){
//                self.currentVC = currentVC
//
//            }
//    }
    
    
}
//TopViewController를 구하기위함.
//TopViewController를 구해서 그곳 위에 네트워크연결끊겼다고 뷰로 나타내기위해서
//extension UIApplication {
//
//    class func topViewController(controller: UIViewController? = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive})
//                                    .map({($0 as? UIWindowScene)!})
//                                            .first?.windows
//                                            .filter({$0.isKeyWindow}).first?.rootViewController ) -> UIViewController?
//    {
//        if let navigationController = controller as? UINavigationController {
//            return topViewController(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topViewController(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return topViewController(controller: presented)
//        }
//        return controller
//    }
//
//
//}
//topViewController 여깄는거 가져와서 바꿈.
//현재 windows는 사용못해서위에 connectedScenes를 이용.
//https://stackoverflow.com/questions/36284476/top-most-viewcontroller-under-uialertcontroller


