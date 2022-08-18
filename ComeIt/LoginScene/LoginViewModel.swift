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
    
    func githubLoginButtonDidTap() {
        FirebaseAPI.shared.logIn()
    }
}

