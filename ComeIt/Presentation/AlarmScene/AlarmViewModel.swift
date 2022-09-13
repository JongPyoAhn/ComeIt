//
//  AlarmViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/09/11.
//

import Foundation
import Combine
class AlarmViewModel{
    
    var alertsPublisher: AnyPublisher<[Alert] ,Never>{
        self.$alerts.eraseToAnyPublisher()
    }
    
    @Published var alerts: [Alert] = []
    
//    var alertsRequested = PassthroughSubject<[Alert], Never>()
    var addAlertSceneRequested = PassthroughSubject<Void ,Never>()
    
    func alertList(){
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        self.alerts = alerts
//        self.alertsRequested.send(alerts)
    }
    
    func alertsOnOffSetting(){
        for i in 0..<alerts.count{
            if !UserDefaults.standard.bool(forKey: "isCommit"){
                alerts[i].isOn = true
            }else{
                alerts[i].isOn = false
            }
        }
    }
    
    func alertsUserDefaultSetting(_ alerts: [Alert]){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey:  "alerts")
    }
}
