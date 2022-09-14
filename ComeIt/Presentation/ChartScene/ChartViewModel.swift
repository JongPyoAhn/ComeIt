//
//  ChartViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import Combine

final class ChartViewModel{
    private var subscription = Set<AnyCancellable>()
    
    @Published var user: User
    @Published var repositories: [Repository]
    @Published var repositoryCommitCountDict = [String:Int]()
    
    var languageDictRequested = PassthroughSubject<[String: Int], Never>()
    
    var userPublisher: AnyPublisher<User, Never>{
        self.$user.eraseToAnyPublisher()
    }
    var repositoriesPublisher: AnyPublisher<[Repository], Never>{
        self.$repositories.eraseToAnyPublisher()
    }
    var repositoryCommitCountDictPublisher: AnyPublisher<[String:Int], Never>{
        self.$repositoryCommitCountDict.eraseToAnyPublisher()
    }
    
    
    init(user: User, repositories: [Repository]){
        self.user = user
        self.repositories = repositories
        self.repositoryCommitCountToDictionary()
    }
    
    
    func setLanguageDict(){
        var languageDict = [String: Int]()
        for i in repositories{
            languageDict["\(i.language)"] = 0
        }
        for i in repositories{
            languageDict["\(i.language)"]! += 1
        }
        self.languageDictRequested.send(languageDict)
    }
    
    func getContributionImageURL() -> AnyPublisher<URL, Never>{
        Just(user.name)
            .map{"https://ghchart.rshah.org/\($0)"}
            .map{URL(string: $0)}
            .filter{$0 != nil}
            .map{$0!}
            .eraseToAnyPublisher()
    }
    
//    func commitToDict(_ repositories: [Repository], completion: @escaping ()->Void){
//        for i in repositories{
//            GithubController.fetchCommit(user.name, i.name)
//                .sink(receiveCompletion: { completion in
//                    switch completion{
//                    case .finished:
//                        print("ChartViewController-fetchCommit : finished")
//                    case .failure(let err):
//                        print("ChartViewController-fetchCommit : \(err)")
//                    }
//                }, receiveValue: { commits in
//                    let latestCommit = commits.last!
//                    self.repoTotal[i.name] = latestCommit.total
//                    if self.repoTotal.count >= 5{
//                        DispatchQueue.main.async {
//                            completion()
//                        }
//                    }
//                })
//                .store(in: &subscription)
//        }
//    }
    
    func repositoryCommitCountToDictionary(){
        for i in repositories{
            GithubController.fetchCommit(user.name, i.name)
                .sink(receiveCompletion: { completion in
                    switch completion{
                    case .finished:
                        print("ChartViewController-fetchCommit : finished")
                    case .failure(let err):
                        print("ChartViewController-fetchCommit : \(err)")
                    }
                }, receiveValue: {[weak self] commits in
                    let latestCommit = commits.last!
                    self?.repositoryCommitCountDict[i.name] = latestCommit.total
//                    if respositoryCommitCount.count >= 5{
//                        DispatchQueue.main.async {
//                            completion()
//                        }
//                    }
                })
                .store(in: &subscription)
        }
        
    }
}
