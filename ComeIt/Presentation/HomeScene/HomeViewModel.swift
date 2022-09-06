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
    
    var defaultSelectedRepositoryNameRequested = PassthroughSubject<String, Never>()
    var defaultIndexOfSelectedRepositoryRequested = PassthroughSubject<Int, Never>()
    
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
    
    func getDefaultSelectedRepositoryName() -> String{
        var defaultSelectedRepositoryName = ""
        if let SelectedRepositoryName = UserDefaults.standard.string(forKey: "currentSelectedRepository"){
            defaultSelectedRepositoryName = SelectedRepositoryName
        }
        self.defaultSelectedRepositoryNameRequested.send(defaultSelectedRepositoryName)
        return defaultSelectedRepositoryName
    }
    
    func getDefaultIndexOfSelectedRepository(_ defaultSelectedRepository: String) -> Int{
        var indexOfSelectedRepository = 0
        if let index = repositoriesNames.firstIndex(of: defaultSelectedRepository) {
            indexOfSelectedRepository = index
        }
        self.defaultIndexOfSelectedRepositoryRequested.send(indexOfSelectedRepository)
        return indexOfSelectedRepository
    }
    
    
}
