//
//  SplashViewController.swift
//  ComeIt
//
//  Created by 안종표 on 2022/08/19.
//

import UIKit

class SplashViewController: UIViewController {
    var viewModel: SplashViewModel!
    init?(viewModel: SplashViewModel, coder: NSCoder){
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1){[weak self] in
            self?.viewModel.validateAccount()
        }
        
    }
    

  

}
