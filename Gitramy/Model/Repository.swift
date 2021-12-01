//
//  Repository.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/02.
//

import UIKit

struct Repository: Decodable{
    var id: Int
    var name: String
    var full_name: String
    var language: String
    
    enum codingKeys: String, CodingKey {
        case id, name, full_name
    }
}
