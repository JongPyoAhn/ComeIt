//
//  AddAlertViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/12.
//

import UIKit
import Combine

import CombineCocoa

protocol AddAlertViewControllerDelegate: AnyObject{
    func addAlert(_ alert: Alert)
}

class AddAlertViewController: UIViewController {
    private var subscription = Set<AnyCancellable>()
    var viewModel: AddAlertViewModel
    private weak var delegate: AddAlertViewControllerDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    init?(viewModel: AddAlertViewModel,delegate: AddAlertViewControllerDelegate?,coder: NSCoder) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    func bindUI(){
        self.viewModel.saveButtonDidTappedRequested
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.dismiss(animated: true)
            }
            .store(in: &subscription)
        
        self.viewModel.cancelButtonDidTappedRequested
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.dismiss(animated: true)
            }
            .store(in: &subscription)
        
        self.cancelButton.tapPublisher
            .sink {[weak self] _ in
                self?.viewModel.cancelButtonDidTapped()
            }
            .store(in: &subscription)
        
        self.saveButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                guard let self = self else{return}
                let alert = self.viewModel.makeNewAlert(self.datePicker.date)
                self.delegate?.addAlert(alert)
                self.viewModel.saveButtionDidTapped()
            }
            .store(in: &subscription)
    }
        
}
