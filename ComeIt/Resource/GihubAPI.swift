//
//  GihubAPI.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/23.
//

import Foundation
import Moya
enum GihubAPI{
    case fetchUser
    case fetchRepository(_ name: String)
    case fetchCommit(_ name: String, _ repository: String)
}
extension GihubAPI: TargetType{
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .fetchUser:
            return "/user"
        case .fetchRepository(let name):
            return "/users/\(name)/repos"
        case .fetchCommit(let name, let repository):
            return "/repos/\(name)/\(repository)/stats/commit_activity"
        }
    }
    
    var method: Moya.Method {
        switch self{
        case .fetchUser, .fetchRepository(_), .fetchCommit(_, _):
            return .get
        }
    }
    
    var task: Task {
        switch self{
        case .fetchUser, .fetchRepository(_), .fetchCommit(_, _):
            return .requestPlain
        }

    }
    
    var headers: [String : String]? {
        switch self{
        case .fetchUser, .fetchRepository(_), .fetchCommit(_, _):
            let header = [
                "Accept": "application/vnd.github.v3+json"
            ]
            return header
        }
    }
    
    
}
