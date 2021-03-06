//
//  User.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit

//파이어베이스에서도 기본적인 User를 제공하지만, 내가 원하는형태의 유저정보를 사용하기위해 직접 모델링해서 싱글톤으로 사용
struct User : Codable{
    var imageURL: String
    var name: String
    var company: String
    var email: String
    var reposPublic: Int
    var reposPrivate: Int
    
    
    
    enum codingkeys: String, CodingKey {
        case imageURL = "avatar_url"
        case name = "login"
        case company, email
        case reposPublic = "public_repos"
        case reposPrivate = "total_private_repos"
    }
    //email, company등이 null값이 들어올 수 있음.
    //container는 codingkeys에 있는것들임.
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingkeys.self)
        imageURL = try values.decode(String.self, forKey: .imageURL)
        name = try values.decode(String.self, forKey: .name)
        company = (try? values.decode(String.self, forKey: .company)) ?? "없습니다."
        email = (try? values.decode(String.self, forKey: .email)) ?? "없습니다."
        reposPublic = try values.decode(Int.self, forKey: .reposPublic)
        reposPrivate = try values.decode(Int.self, forKey: .reposPrivate)
        
    }

}


//https://api.github.com/users/JongPyoAhn
//https://taetaetae.github.io/2017/03/02/github-api/

