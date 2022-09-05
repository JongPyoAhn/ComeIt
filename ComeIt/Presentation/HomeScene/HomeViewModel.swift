//
//  HomeViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import Combine

final class HomeViewModel{
    var userPublisher: AnyPublisher<User, Never>{ self.$user.eraseToAnyPublisher() }
    var repositoriesPublisher: AnyPublisher<[Repository], Never> { self.$repositories.eraseToAnyPublisher() }
    var repositoriesCount: Int{ self.repositories.count }
    var repositoriesNames: [String]{
        self.repositories.map{ $0.name }
    }
    
    @Published var user: User
    @Published var repositories: [Repository]
    
    init(user: User, repositories: [Repository]){
        self.user = user
        self.repositories = repositories
        
    }
    
    //오늘요일수 구하는 함수(1~7) 일,월,화...,토
    func getNowDay() -> AnyPublisher<Character, Never>{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        let dayOfWeekChr = dateFormatter.string(from: nowDate)
        return dayOfWeekChr.publisher.eraseToAnyPublisher()
    }
}
