//
//  ChartViewModel.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/26.
//

import Foundation
import Combine

final class ChartViewModel{
    var user: User
    var repositories: [Repository]
    
    init(user: User, repositories: [Repository]){
        self.user = user
        self.repositories = repositories
    }


}
