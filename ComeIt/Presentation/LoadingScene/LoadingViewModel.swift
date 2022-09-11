//
//  LoginViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/24.
//

import Foundation
import Combine

import CombineMoya
import Moya

final class LoadingViewModel{
    
    
    private var subscription = Set<AnyCancellable>()
    
    var tabbarPageRequested = PassthroughSubject<(User, [Repository]), Never>()
    var loginPageRequested = PassthroughSubject<Void, Never>()
    var repositoryFetchRequested = PassthroughSubject<User, Never>()
    
    func requestFetchUser(){
        GithubController.fetchUser()
            .sink {[weak self] completion in
                switch completion{
                case .finished:
                    print("requestFetchUserAndRepository - Finished")
                case .failure(let err):
                    print("requestFetchUserAndRepository - \(err)")
                    if err as! NetworkingError == NetworkingError.invalidUserToken(401){
                        FirebaseAPI.shared.logout()
                        self?.loginPageRequested.send()
                    }
                }
            } receiveValue: {[weak self] response in
                do{
                    let user = try JSONDecoder().decode(User.self, from: response.data)
                    print(user)
                    self?.repositoryFetchRequested.send(user)
                }catch(let err){
                    print("LoadingViewModel-UserDecodingError : \(err)")
                }
            }
            .store(in: &subscription)
    }
   

    func requestFetchRepository(_ user: User){
        GithubController.fetchRepository(user.name)
            .sink(receiveCompletion: { completion in
                switch completion{
                case .finished:
                    print("LoadingViewModel-requestFetchRepository : Finished")
                case .failure(let err):
                    print("LoadingViewModel-requestFetchRepository : \(err)")
                }
            }, receiveValue: {[weak self] response in
                do{
                    let repositories = try JSONDecoder().decode([Repository].self, from: response.data)
                    self?.tabbarPageRequested.send((user, repositories))
                }catch(let err){
                    print("LoadingViewModel-[Repository] DecodingError : \(err)")
                }
            })
            .store(in: &subscription)
    }
}

