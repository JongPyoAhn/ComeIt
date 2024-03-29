//
//  SplashViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/19.
//

import Foundation
import Combine

import FirebaseAuth


final class SplashViewModel{
    var errorPublisher: AnyPublisher<Error?, Never>{
        self.$error.eraseToAnyPublisher()
    }
    @Published var error: Error?
    
    var loginPageRequested = PassthroughSubject<Void, Never>()
    var loadingPageRequested = PassthroughSubject<Void, Never>()
    
    var firebaseAPI = FirebaseAPI.shared
    var subscription = Set<AnyCancellable>()
    
    func validateAccount(){
        firebaseAPI.getCurrentUser()
            .sink {[weak self] completion in
                switch completion{
                case .finished:
                    print("SplashViewModel-firebaseAPI-getCurrentUser() : finished")
                case .failure(let err):
                    print("SplashViewModel-firebaseAPI-getCurrentUser() : \(err)")
                    self?.error = err
                }
            } receiveValue: {[weak self] firebaseUser in
                if let _ = firebaseUser, let userAccessToken = UserDefaults.standard.string(forKey: "userAccessToken") {
                    print(userAccessToken)
                    self?.firebaseAPI.userAccessToken = userAccessToken
                    self?.loadingPageRequested.send()
                }else{
                    self?.loginPageRequested.send()
                }

            }
            .store(in: &subscription)
    }
}
