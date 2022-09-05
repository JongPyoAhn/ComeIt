//
//  LoginViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/16.
//

import Foundation
import Combine

import FirebaseAuth

protocol LoginViewModelInput{
    func githubLoginButtonDidTap()
}
protocol LoginViewModelOutput{
    
}

typealias LoginViewModelProtocol = LoginViewModelInput & LoginViewModelOutput

final class LoginViewModel: LoginViewModelProtocol{
    
    var credentialPass = PassthroughSubject<Void, Never>()
    
    var subscription = Set<AnyCancellable>()
    
    func githubLoginButtonDidTap() {
        logIn()
    }
    
    func logIn(){
        let firebaseAPI = FirebaseAPI.shared
        firebaseAPI.getCredential()
            .print()
            .sink { completion in
                switch completion{
                case .finished:
                    print("LoginViewModel-FirebaseAPI-getCredential() - finished")
                case .failure(let err):
                    print("LoginViewModel-FirebaseAPI-getCredential() - \(err)")
                }
            } receiveValue: {[weak self] authDataResult in
                guard let self = self else {return}
                guard let oAuthCredential = authDataResult.credential as? OAuthCredential else {return}
                guard let accessToken = oAuthCredential.accessToken else {return}
                print("accessToken : \(accessToken)")
                firebaseAPI.userAccessToken = accessToken
                self.credentialPass.send()
                UserDefaults.standard.set(oAuthCredential.accessToken, forKey: "userAccessToken")
            }
            
            .store(in: &subscription)
    }
    
}

