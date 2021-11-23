//
//  TotalViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import Kingfisher
import PocketSVG
import Charts
import SwiftUI
import CoreMedia

class ChartViewController: UIViewController, ChartViewDelegate {
    let loginManager = LoginManager.shared


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contributionStackView: UIStackView!
    @IBOutlet weak var contributionView: UIView!
    
    @IBOutlet weak var repositoryChartView: LineChartView!
    @IBOutlet weak var languageChartView: BarChartView!
    
    
    var repositoryNames: [String] = []//x축을 레파지토리 이름 받아오기
    let languageNames = ["Swift", "Java", "python", "Ruby", "C++"]//
    let test = ["Swift", "Java", "python", "Ruby", "C++"]
    
    //모든 레포지토리 데이터 받아와서 y축을 총커밋수
    var repositoryValues: [ChartDataEntry] = []
    
    let languageValues: [BarChartDataEntry] = [
        BarChartDataEntry(x: 0, y: 0.5),
        BarChartDataEntry(x: 1, y: 0.1),
        BarChartDataEntry(x: 2, y: 0.2),
        BarChartDataEntry(x: 3, y: 0.4),
        BarChartDataEntry(x: 4, y: 0.6)
    ]
    
    let refresh = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLineChartView()
        repositorySetData()
        setBarChartView()
        languageSetData(languageValues)
        initRefresh()
        //웹URL SVG가져오기.
        print("subViewCounts : \(contributionStackView.arrangedSubviews.count)")
        if contributionStackView.arrangedSubviews.count < 2{
            getContributionSvgImageFile()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //커밋 수 많은 위에서 5개만 추려야됨.
        //dict에서 오름차순이나 내림차순으로 쓰기.
        
    }
    func getContributionSvgImageFile(){
        let imageURL = URL(string: "https://ghchart.rshah.org/\(self.loginManager.user.name)")
        let svgImageView = SVGImageView.init(contentsOf: imageURL!)
        svgImageView.frame = view.bounds
        svgImageView.contentMode = .scaleAspectFit
        if contributionStackView.arrangedSubviews.count >= 2{
            contributionStackView.removeArrangedSubview(svgImageView)
        }else {
            contributionStackView.addArrangedSubview(svgImageView)
        }
    }
    
}
//MARK: -refresh
extension ChartViewController{
    func initRefresh() {
        refresh.addTarget(self, action: #selector(updateUI), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        //UIRefreshControl의 attributedTitle
        refresh.attributedTitle = NSAttributedString(string: "데이터를 불러오는중...",
                                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        //ScrollView에 UIRefreshControl 적용
        self.scrollView.refreshControl = refresh
    }
    
    @objc func updateUI(){
        if !repositoryNames.isEmpty{
            repositoryNames.removeAll()
            repositoryValues.removeAll()
            repositoryChartView.clear()
        }
        self.loginManager.commitToDict()
        print("repoTotal : \(self.loginManager.repoTotal)")
        setLineChartView()
        repositorySetData()
        setBarChartView()
        languageSetData(languageValues)
        
        getContributionSvgImageFile()
        
        
        
        self.refresh.endRefreshing() //새로고침종료
    }
}

//차트관련
extension ChartViewController {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    //MARK: - 레포지토리 꺽은선 그래프
    func repositorySetData(){
        var x: Double = 0
        for i in repositoryNames{
            let repoTotal = self.loginManager.repoTotal[i]!
            repositoryValues.append(ChartDataEntry(x: x, y: Double(repoTotal)))
            x += 1.0 //xLabel에 이름이 안나왔던 원인임 차트는 1.0단위로해줘야함 ㅠㅠㅠㅠ
            //그동안 10으로해서 안나왔던것이다ㅠㅠㅠㅠㅠㅠㅠㅠㅠ
        }
        print(repositoryValues)
        let set1 = LineChartDataSet(entries: repositoryValues, label: "🙈레포지토리 커밋개수")
        set1.lineWidth = 5 //선의 굵기
        //그래프 바깥쪽 원 크기와 색상
        set1.circleColors = [NSUIColor.init(rgb: 0xFF5500)]
        set1.circleRadius = 5.0
        //그래프 안쪽 원 크기와 색상
        set1.circleHoleColor = UIColor.white
        set1.circleHoleRadius = 4.0
//        set1.mode = .cubicBezier //선 유연하게
        set1.setColor(UIColor(rgb: 0xFF7F00)) //선의 색깔
        set1.highlightColor = .systemRed //누르면서 움직이면 빨간색나오게함
        
        
        
        //누르고 쭉 당기면 노란줄생기는거 없어짐.
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        
        //그래프밑에 색 채우는거
        let gradient = getGradientFilling()
        set1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        set1.drawFilledEnabled = true
        set1.valueFormatter = DefaultValueFormatter(decimals: 0)//꼭지점에서 소수점없애기
        set1.valueFont = UIFont.boldSystemFont(ofSize: 10)
        
        //        set1.mode = .stepped //선의 종류
//        set1.drawCirclesEnabled = false //선 꼭짓점에 생기던 동그란원이 사라짐
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(.black)
        data.setDrawValues(true)//꼭지점에 데이터표시
        
        repositoryChartView.data = data
        
        //그래프 밑에 색 채우는거
        func getGradientFilling() -> CGGradient {
            let coloTop = UIColor(rgb: 0xFF6A00).cgColor
            let colorBottom = UIColor(rgb: 0xFFFDABF).cgColor
            // Colors of the gradient
            let gradientColors = [coloTop, colorBottom] as CFArray
            // Positioning of the gradient
            let colorLocations: [CGFloat] = [0.7, 0.0]
            // Gradient Object
            return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
        }

    }
    
    //꺽은선그래프 꾸미기
    func setLineChartView(){
        //repoTotal딕셔너리에서 totalRepo가 많은순으로 내림차순 정렬
        var sorted = self.loginManager.repoTotal.sorted { $0.value > $1.value}
        //저장소이름은 오름차순 정렬 딱히 의미x
        sorted.sort{
            $0.key < $1.key
        }
        for i in 0...4{
            self.repositoryNames.append(sorted[i].key)
        }
        print("repositoryNames : \(repositoryNames)")
        repositoryChartView.backgroundColor = .white
        repositoryChartView.rightAxis.enabled = false
        
        //뷰 모서리 둥글게
        repositoryChartView.layer.cornerRadius = 20
        repositoryChartView.layer.masksToBounds = true
        repositoryChartView.legend.verticalAlignment = .top //범례 위치 지정.
        repositoryChartView.legend.textColor = UIColor.black//범례 텍스트 색상지정.
        repositoryChartView.legend.form = .circle
        repositoryChartView.layer.borderWidth = 2
        repositoryChartView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        
        let yAxis = repositoryChartView.leftAxis
        let xAxis = repositoryChartView.xAxis
        yAxis.setLabelCount(repositoryNames.count, force: true) //왼쪽 y축 눈금의 수를 설정
        
        yAxis.enabled = false
//        yAxis.gridColor = .clear //격자 선 지우기
//        yAxis.labelTextColor = .black //왼쪽 y축 눈금의 색을 설정
//        yAxis.axisLineColor = .black //왼쪽 y축 눈금선의 색을 설정
//        yAxis.valueFormatter = DefaultAxisValueFormatter(decimals: 0)

        print("여기 : \(repositoryNames)")
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: repositoryNames)
        xAxis.setLabelCount(repositoryNames.count, force: true) //x축 레이블의 수를 설정
        xAxis.labelPosition = .top //x축 눈금 위치 조정
//        xAxis.granularity = 1
        xAxis.gridColor = .clear
        xAxis.granularityEnabled = true
    
        xAxis.labelFont = .boldSystemFont(ofSize: 8) //x축 폰트 설정
        

//        repositoryChartView.data?.setDrawValues(false)
        xAxis.labelTextColor = .black //x축 글자색깔
        xAxis.axisLineColor = .clear //x축 눈금선의 색을 설정
        
       
        
        repositoryChartView.doubleTapToZoomEnabled = false
        repositoryChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)//애니메이션 설정
        repositoryChartView.fitScreen()
    }
    
  
    //        yAxis.labelFont = .boldSystemFont(ofSize: 12) //왼쪽 y축 눈금의 폰트를 설정


    
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
        
//        xAxis.labelPosition = .bottom //위에 있던 x축 눈금이 아래로 내려옴
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .boldSystemFont(ofSize: 12) //x축 폰트 설정
        xAxis.labelTextColor = .white //x축 글자색깔
        xAxis.axisLineColor = .clear //x축 눈금선의 색을 설정
        
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values:languageNames)
        xAxis.granularity = 1
        
        languageChartView.doubleTapToZoomEnabled = false
    }
    
}
//HexColor Using
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
