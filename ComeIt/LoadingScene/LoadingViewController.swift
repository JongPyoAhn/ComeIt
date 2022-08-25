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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension LoadingViewController{
    func configureUI(){
        gifImageView.animate(withGIFNamed: "Loading")
    }
}

//escapingClosure : https://dongminyoon.tistory.com/1
