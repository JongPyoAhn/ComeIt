//
//  Alert.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/12.
//

import Foundation
struct Alert: Codable {
    var id: String = UUID().uuidString
    var date: Date
    var isOn: Bool
    
    
    var time: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter.string(from: date)
    }
    
    var meridium: String {
        let meridiumFormatter = DateFormatter()
        meridiumFormatter.dateFormat = "a"
        meridiumFormatter.locale = Locale(identifier: "ko")
        return meridiumFormatter.string(from: date)
    }
}
