//
//  LoadingViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/07.
//

import UIKit
import Combine

import FirebaseAuth
import Gifu
import Moya

class LoadingViewController: UIViewController {
    @IBOutlet weak var gifImageView: GIFImageView!
    private var viewModel: LoadingViewModel!
    private var subscription = Set<AnyCancellable>()
    
    init?(viewModel: LoadingViewModel, coder: NSCoder){
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
}

extension LoadingViewController{
    private func configureUI(){
        gifImageView.animate(withGIFNamed: "Loading")
    }
    private func bind(){
//        viewModel.request()
        viewModel.requestFetchUser()
        viewModel.repositoryFetchRequested
            .sink {[weak self] user in
                self?.viewModel.requestFetchRepository(user)
            }
            .store(in: &subscription)
        
    }
}

//escapingClosure : https://dongminyoon.tistory.com/1
