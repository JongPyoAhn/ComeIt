//
//  ChartViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import Combine

import Charts

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

}

//MARK: - common
extension ChartViewModel{
    func getContributionImageURL() -> AnyPublisher<URL, Never>{
        Just(user.name)
            .map{"https://ghchart.rshah.org/\($0)"}
            .map{URL(string: $0)}
            .filter{$0 != nil}
            .map{$0!}
            .eraseToAnyPublisher()
    }
    
    func sortDescendingDictValue(_ dict: [String: Int]) -> [String: Int]{
        return Dictionary(uniqueKeysWithValues: dict.sorted(by: {$0.value > $1.value}))
    }

}

//MARK: - repositoryChart
extension ChartViewModel{
    
    func sortAscendingDictKey(_ dict: [String: Int]) -> [(String, Int)]{
        //저장소이름은 오름차순 정렬 딱히 의미x
        return dict.sorted(by: {$0.key < $1.key})
    }
    
    func repositoryNamesSetting(_ repositoryCommitCountDictSorted: [(String, Int)]) -> [String]{
        var repositoryNames: [String] = []
        if repositoryCommitCountDictSorted.count > 4{
            for i in 0...4{
                repositoryNames.append(repositoryCommitCountDictSorted[i].0)
            }
        }else {
            for i in 0..<repositoryCommitCountDictSorted.count{
                repositoryNames.append(repositoryCommitCountDictSorted[i].0)
            }
        }
        return repositoryNames
    }
    
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
                })
                .store(in: &subscription)
        }
        
    }
    func getLineChartXLabel(_ repositoryNames: [String]) -> [ChartDataEntry]{
        var x: Double = 0
        var repositoryValues: [ChartDataEntry] = []
        
        for i in repositoryNames{
            let repoTotal = self.repositoryCommitCountDict[i]!
            repositoryValues.append(ChartDataEntry(x: x, y: Double(repoTotal)))
            x += 1.0 //xLabel에 이름이 안나왔던 원인임 차트는 1.0단위로해줘야함 ㅠㅠㅠㅠ
            //그동안 10으로해서 안나왔던것이다ㅠㅠㅠㅠㅠㅠㅠㅠㅠ
        }
        return repositoryValues
    }
}
//MARK: - languageChart
extension ChartViewModel{
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
    
    func filterLanguageChartData(_ sortedDict: [String: Int]) -> ([String], [Int]){
        var chartLanguageName: [String] = []
        var chartLanguageValue: [Int] = []
        
        for (key, value) in sortedDict{
            if chartLanguageName.count > 4{
                break
            }
            if key != "Null" && key != "없음"{
                chartLanguageName.append(key)
                chartLanguageValue.append(value)
            }
        }
        if chartLanguageName.isEmpty{
            chartLanguageName.append("Null")
            chartLanguageValue.append(1)
        }
        
        return (chartLanguageName, chartLanguageValue)
    }
    
    func getPieChartEntry(_ chartLanguageName: [String] , _ chartLanguageValue: [Int]) -> [PieChartDataEntry]{
        var entries = [PieChartDataEntry]()
        for (index, value) in chartLanguageValue.enumerated() {
            let entry = PieChartDataEntry(value: Double(value), label: "\(chartLanguageName[index])", data: value)
            entries.append(entry)
        }
        return entries
    }
    
}
