//
//  GithubController.swift
//  ComeIt
//
//  Created by 안종표 on 2022/04/14.
//

import UIKit
import Combine

import Moya
import CombineMoya

enum NetworkingError: Error, Equatable{
    case invalidUserToken(_ statusCode: Int)
    case internalError(_ statusCode: Int)
    case serverError(_ statusCode: Int)
}

final class GithubController{
    private var subscription = Set<AnyCancellable>()
    private static var provider: MoyaProvider<GithubAPI>!
    private static let githubEndPointClosure = { (target: GithubAPI) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        default:
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(String(describing: FirebaseAPI.shared.userAccessToken))"])
        }
    }
    
    static func fetchUser() -> AnyPublisher<Response, Error>{
        provider = MoyaProvider<GithubAPI>(endpointClosure: githubEndPointClosure)
        return provider.requestPublisher(.fetchUser)
            .mapError({ moyaError in
                moyaError as Error
            })
            .eraseToAnyPublisher()
    }
    
    static func fetchRepository(_ userName: String) -> AnyPublisher<Response, Error>{
        provider = MoyaProvider<GithubAPI>(endpointClosure: githubEndPointClosure)
        return provider.requestPublisher(.fetchRepository(userName))
            //fetchUser에서 에러잡고한다.
            .filterSuccessfulStatusCodes()
            .mapError({ moyaError in
                moyaError as Error
            })
            .eraseToAnyPublisher()
    }
    
    static func fetchCommit( _ userName: String, _ repositoryName: String) -> AnyPublisher<[Commit], Error> {
        provider = MoyaProvider<GithubAPI>(endpointClosure: githubEndPointClosure)
        return provider.requestPublisher(.fetchCommit(userName, repositoryName))
            .map([Commit].self)
            .mapError { moyaError in
                return moyaError as Error
            }
            .eraseToAnyPublisher()
    }
}
