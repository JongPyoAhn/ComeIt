//
//  Repository.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/02.
//

import UIKit

//널값 체크를 안해줘서 개오래걸림. 다음부턴 조심.
struct Repository: Codable{
    let name: String
    let language: String
    
    enum codingkeys: String, CodingKey{
        case name, language
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingkeys.self)
        name = try values.decode(String.self, forKey: .name)
        language = (try? values.decode(String.self, forKey: .language)) ?? "없음"
    }
}
//
