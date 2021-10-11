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

class ChartViewController: UIViewController, ChartViewDelegate {


    @IBOutlet weak var contributionImageView: UIImageView!
    
    @IBOutlet weak var repositoryChartView: LineChartView!
    @IBOutlet weak var languageChartView: BarChartView!
    
    
    let repositoryNames = ["Algorithm", "mainProject", "subProject", "test", "test12"]//x축을 레파지토리 이름 받아오기
    let languageNames = ["Swift", "Java", "python", "Ruby", "C++"]//
    
    
    //모든 레포지토리 데이터 받아와서 y축을 총커밋수
    let repositoryValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0, y: 50),
        ChartDataEntry(x: 1, y: 30),
        ChartDataEntry(x: 2, y: 20),
        ChartDataEntry(x: 3, y: 60),
        ChartDataEntry(x: 4, y: 40)
    ]
    
    let languageValues: [BarChartDataEntry] = [
        BarChartDataEntry(x: 0, y: 0.5),
        BarChartDataEntry(x: 1, y: 0.1),
        BarChartDataEntry(x: 2, y: 0.2),
        BarChartDataEntry(x: 3, y: 0.4),
        BarChartDataEntry(x: 4, y: 0.6)
    ]
    
    let imageURL = URL(string: "https://ghchart.rshah.org/JongpyoAhn")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLineChartView()
        setBarChartView()
        repositorySetData(repositoryValues)
        languageSetData(languageValues)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fistBump = UIView(SVGURL: imageURL!)
        self.contributionImageView.addSubview(fistBump)
    }
}


//차트관련
extension ChartViewController {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    //MARK: - 레포지토리 꺽은선 그래프
    func repositorySetData(_ values: [ChartDataEntry]){
        let set1 = LineChartDataSet(entries: values, label: "Repository")
//        set1.mode = .stepped //선의 종류
        set1.drawCirclesEnabled = false //선 꼭짓점에 생기던 동그란원이 사라짐
        set1.lineWidth = 3 //선의 굵기
        set1.setColor(.white) //선의 색깔
        set1.drawHorizontalHighlightIndicatorEnabled = false //누르고 쭉 당기면 노란줄생기는거 없어짐.
        set1.drawVerticalHighlightIndicatorEnabled = false //누르고 쭉 당기면 노란줄생기는거 없어짐.
        set1.highlightColor = .systemRed //누르면서 움직이면 빨간색나오게함
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        repositoryChartView.data = data
    }
    
    //꺽은선그래프 꾸미기
    func setLineChartView(){
        repositoryChartView.backgroundColor = .darkGray
        repositoryChartView.rightAxis.enabled = false
        
        let yAxis = repositoryChartView.leftAxis
        let xAxis = repositoryChartView.xAxis

        yAxis.gridColor = .clear //격자 선 지우기
        xAxis.gridColor = .clear

        yAxis.labelFont = .boldSystemFont(ofSize: 12) //왼쪽 y축 눈금의 폰트를 설정
        yAxis.setLabelCount(repositoryValues.count, force: false) //왼쪽 y축 눈금의 수를 설정
        yAxis.labelTextColor = .white //왼쪽 y축 눈금의 색을 설정
        yAxis.axisLineColor = .white //왼쪽 y축 눈금선의 색을 설정
        
        xAxis.labelPosition = .bottom //위에 있던 x축 눈금이 아래로 내려옴.
        xAxis.labelFont = .boldSystemFont(ofSize: 12) //x축 폰트 설정
        xAxis.setLabelCount(repositoryValues.count, force: true) //x축 레이블의 수를 설정
        xAxis.labelTextColor = .white //x축 글자색깔
        xAxis.axisLineColor = .clear //x축 눈금선의 색을 설정
        
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values:repositoryNames)
        xAxis.granularity = 1
        
        repositoryChartView.doubleTapToZoomEnabled = false
        repositoryChartView.animate(xAxisDuration: 2.5) //애니메이션 설정
    }
    
    //MARK: - 언어 막대그래프
    func languageSetData(_ values: [BarChartDataEntry]){
        let set2 = BarChartDataSet(entries: values, label: "Language")
        let data = BarChartData(dataSet: set2)
        data.setDrawValues(false)
        languageChartView.data = data
    }
    
    func setBarChartView(){
        languageChartView.backgroundColor = .darkGray
        languageChartView.rightAxis.enabled = false
        
        let yAxis = languageChartView.leftAxis
        let xAxis = languageChartView.xAxis
        
        yAxis.gridColor = .clear //격자 선 지우기
        xAxis.gridColor = .clear

        yAxis.labelFont = .boldSystemFont(ofSize: 12) //왼쪽 y축 눈금의 폰트를 설정
        yAxis.labelTextColor = .white //왼쪽 y축 눈금의 색을 설정
        yAxis.axisLineColor = .white //왼쪽 y축 눈금선의 색을 설정

        xAxis.labelPosition = .bottom //위에 있던 x축 눈금이 아래로 내려옴
        xAxis.labelFont = .boldSystemFont(ofSize: 12) //x축 폰트 설정
        xAxis.labelTextColor = .white //x축 글자색깔
        xAxis.axisLineColor = .clear //x축 눈금선의 색을 설정
        
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values:languageNames)
        xAxis.granularity = 1
        
        languageChartView.doubleTapToZoomEnabled = false
    }
    
}
