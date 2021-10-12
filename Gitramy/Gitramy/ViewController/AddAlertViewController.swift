//
//  AddAlertViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/12.
//

import UIKit

class AddAlertViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func cancelButtonTabbed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTabbed(_ sender: Any) {
        
    }
}
