//
//  GihubAPI.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/23.
//

import Foundation
import Moya
enum GithubAPI{
    case fetchUser
    case fetchRepository(_ name: String)
    case fetchCommit(_ userName: String, _ repository: String)
}
extension GithubAPI: TargetType{
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .fetchUser:
            return "/user"
        case .fetchRepository(let name):
            return "/users/\(name)/repos"
        case .fetchCommit(let userName, let repository):
            return "/repos/\(userName)/\(repository)/stats/commit_activity"
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
