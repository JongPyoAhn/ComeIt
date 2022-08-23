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
    
    var credential = PassthroughSubject<Void, Never>()
    
    var subscription = Set<AnyCancellable>()
    
    func githubLoginButtonDidTap() {
        logIn()
    }
    
    func logIn(){
        let firebaseAPI = FirebaseAPI.shared
        firebaseAPI.getCredential()
            .sink { completion in
                switch completion{
                case .finished:
                    print("getCredentialAndSignIn - finished")
                case .failure(let err):
                    print("getCredentialAndSignIn - \(err)")
                }
            } receiveValue: {[weak self] authDataResult in
                guard let self = self else {return}
                guard let oAuthCredential = authDataResult.credential as? OAuthCredential else {return}
                guard let accessToken = oAuthCredential.accessToken else {return}
                firebaseAPI.userAccessToken = accessToken
                self.credential.send()
                UserDefaults.standard.set(oAuthCredential.accessToken, forKey: "userAccessToken")
            }.store(in: &subscription)
    }
    
}

