//
//  DisConnectedViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/11/26.
//

import UIKit
import Gifu
class DisConnectedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("111111111111111")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        if NetworkMonitor.shared.isConnected{
            self.dismiss(animated: false, completion: nil)
            
        }
    }
}
