//
//  LoginViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/24.
//

import Foundation
import Combine

import Moya

final class LoadingViewModel{
    
    private var provider: MoyaProvider<GithubAPI>!
    private var subscription = Set<AnyCancellable>()
    
    var tabbarPageRequested = PassthroughSubject<[Repository], Never>()
    
    let endpointClosure = { (target: GithubAPI) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        switch target {
        default:
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(String(describing: FirebaseAPI.shared.userAccessToken))"])
        }
    }
    
    func requestFetchUserAndRepository(){
        provider = MoyaProvider<GithubAPI>(endpointClosure: endpointClosure)
        GithubController.fetchUserAndThenRepository(provider)
            .sink { completion in
                switch completion{
                case .finished:
                    print("requestFetchUserAndRepository - Finished")
                case .failure(let err):
                    print("requestFetchUserAndRepository - \(err)")
                }
            } receiveValue: {[weak self] repositories in
                self?.tabbarPageRequested.send(repositories)
            }
            .store(in: &subscription)


        
//        let githubController = GithubController.shared
//        githubController.requestFetchUser(provider){
//            guard let userName = FirebaseAPI.shared.user?.name else {return}
//            githubController.requestFetchRepository(provider, userName){
//
//            }
//        }
    }
    
    
   
    
}
