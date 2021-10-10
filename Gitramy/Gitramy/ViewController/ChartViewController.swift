//
//  TotalViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import Kingfisher
import SwiftSVG
import Charts
class ChartViewController: UIViewController {


    @IBOutlet weak var contributionImageView: UIImageView!
    
    @IBOutlet weak var lineChartView: LineChartView!
    var numbers: [Double] = []
    
    
    let imageURL = URL(string: "https://ghchart.rshah.org/JongpyoAhn")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numbers = [40, 30, 20, 15, 10]
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.contributionImageView.kf.setImage(with: imageURL)
        let fistBump = UIView(SVGURL: imageURL!)
        self.contributionImageView.addSubview(fistBump)
    }
    
    func lineGraph() {
        
    }
    
    

}


