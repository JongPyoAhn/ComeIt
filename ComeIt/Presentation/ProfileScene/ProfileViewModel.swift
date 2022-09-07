//
//  ProfileViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/09/06.
//

import Foundation
import Combine
import UIKit

import Moya

final class ProfileViewModel{
    
    var userPublisher: AnyPublisher<User, Never>{
        self.$user.eraseToAnyPublisher()
    }
    
    var popViewRequested = PassthroughSubject<Void, Never>()
    var getUrlImageRequested = PassthroughSubject<Data, Never>()
    
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
    
    func getUrlImage(){
        guard let url = URL(string: user.imageURL) else {return}
        guard let data = try? Data(contentsOf: url) else {return}
        self.getUrlImageRequested.send(data)
    }
    
    func moveToRepositoryButtonDidTapped(){
        if let url = URL(string: "https://github.com/\(self.user)?tab=repositories"){
            UIApplication.shared.open(url, options: [:])
        }
    }
}
