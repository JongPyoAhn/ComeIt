//
//  HomeViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import Combine
import UIKit

final class HomeViewModel{
    
    //커밋 0번이면 노티키고 1번이상이면 노티끄기위해서.
    private let userNotification = UNUserNotificationCenter.current()
    private var subscription = Set<AnyCancellable>()
    
    var userPublisher: AnyPublisher<User, Never>{ self.$user.eraseToAnyPublisher() }
    var repositoriesPublisher: AnyPublisher<[Repository], Never> { self.$repositories.eraseToAnyPublisher() }
    var repositoriesCount: Int{ self.repositories.count }
    var repositoriesNames: [String]{
        self.repositories.map{ $0.name }
    }
    
    var defaultSelectedRepositoryNameRequested = PassthroughSubject<String, Never>()
    var defaultIndexOfSelectedRepositoryRequested = PassthroughSubject<Int, Never>()
    var commitLastRequested = PassthroughSubject<Commit, Never>()
    
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
    
    func getCommitLast(_ commits: [Commit]){
        guard let commitLast = commits.last else {return}
        self.commitLastRequested.send(commitLast)
    }
    
    func getLatestDayOfCommitCount(_ commitLast: Commit, _ dayOfWeekInt: Int) -> Int{
        return commitLast.days[dayOfWeekInt - 1]
    }
    
    func commitTextChange(_ row: Int){
        GithubController.fetchCommit(user.name, repositories[row].name)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion{
                case .finished:
                    print("HomeViewController - fetchCommit : Finished")
                case .failure(let err):
                    print("HomeViewController - fetchCommit : \(err)")
                }
            } receiveValue: {[weak self] commits in
                guard let self = self else {return}
                self.getCommitLast(commits)//to -> commitLastRequested
            }
            .store(in: &subscription)
    }
    
    func alertOnOff(_ latestDayOfCommit: Int){
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
        if latestDayOfCommit >= 1 {
            for i in 0..<alerts.count{
                self.userNotification.removePendingNotificationRequests(withIdentifiers: [alerts[i].id])
            }
        }else{
            for i in 0..<alerts.count{
                self.userNotification.addNotificaionRequest(by: alerts[i])
            }
        }
    }
}
