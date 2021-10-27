//
//  User.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit


struct User : Decodable{
    let name: String
    let company: String
    let reposPublic: Int
    let reposPrivate: Int
    
    enum codingkeys: String, CodingKey {
        case company
        case name = "login"
        case reposPublic = "public_repos"
        case reposPrivate = "total_private_repos"
    }
}


//https://api.github.com/users/JongPyoAhn
//https://taetaetae.github.io/2017/03/02/github-api/

