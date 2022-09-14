//
//  AddAlertViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/09/11.
//

import Foundation
import Combine

class AddAlertViewModel{
    
    var cancelButtonDidTappedRequested = PassthroughSubject<Void, Never>()
    var saveButtonDidTappedRequested = PassthroughSubject<Void, Never>()
    
    func cancelButtonDidTapped(){
        self.cancelButtonDidTappedRequested.send()
    }
    
    func saveButtionDidTapped(){
        self.saveButtonDidTappedRequested.send()
    }
    
    func makeNewAlert(_ date: Date) -> Alert{
        var newAlert = Alert(date: date, isOn: true)
        if UserDefaults.standard.bool(forKey: "isCommit"){
            newAlert.isOn = false
        }
        return newAlert
    }
}
