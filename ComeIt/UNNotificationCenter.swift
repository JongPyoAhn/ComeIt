//
//  UNNotificationCenter.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/18.
//

import UIKit
import UserNotifications

extension UNUserNotificationCenter {
    //여기에서 알럿객체를 받아서 리퀘스트를 만들고 최종적으로 노티피케이션 센터에 추가
    func addNotificaionRequest(by alert: Alert){
        let content = UNMutableNotificationContent()
        content.title = "커밋하실 시간이에요"
        content.body = "하루에 한번 커밋하고 쌓인다면 엄청난 나비효과가 생길거에요^^"
        content.sound = .default
        content.badge = 1
    
        
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date)
        
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn)
        
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
     
        self.add(request, withCompletionHandler: nil)
        
        
        
    }
    
}
