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
    var viewModel: LoadingViewModel!
    
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
        viewModel.requestFetchUserAndRepository()
    }
}

//escapingClosure : https://dongminyoon.tistory.com/1
