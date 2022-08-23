//
//  Coordinator.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/18.
//

import Foundation
import UIKit

class Coordinator{
    var childCoordinators: [UUID: Coordinator] = [:]
    
    var identifier: UUID
    var navigationController: UINavigationController
    
    init(identifier: UUID, navigationController: UINavigationController){
        self.identifier = identifier
        self.navigationController = navigationController
    }
}
