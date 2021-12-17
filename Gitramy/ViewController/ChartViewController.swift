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
import RxSwift


class ChartViewController: UIViewController, ChartViewDelegate {
    let loginManager = LoginManager.shared
    static let shared = ChartViewController()
    var languageDict = [String: Int]()
    var language = [String]()
    var languageValue = [Int]()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contributionStackView: UIStackView!
    @IBOutlet weak var contributionView: UIView!
    @IBOutlet weak var repositoryChartView: LineChartView!
    @IBOutlet weak var languagePieChartView: PieChartView!
    
    //rx
    let disposedBag = DisposeBag()
    
    
    var repositoryNames: [String] = []//x축을 레파지토리 이름 받아오기
    let pieChartDataEntries: [PieChartDataEntry] = []
    
    
    //모든 레포지토리 데이터 받아와서 y축을 총커밋수
    var repositoryValues: [ChartDataEntry] = []
    
    let refresh = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle()
        setLanguageDict()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //커밋 수 많은 위에서 5개만 추려야됨.
        //dict에서 오름차순이나 내림차순으로 쓰기.
        
        updateUI()
        print("viewWillAppear")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDisappear")
    }
    func setLanguageDict(){
        for i in self.loginManager.repositories{
            languageDict["\(i.language)"] = 0
        }
        for i in self.loginManager.repositories{
            languageDict["\(i.language)"]! += 1
        }
        print("languageDict: \(languageDict)")
    }
    
    func setNavigationTitle(){
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
    }

    
    func getContributionSvgImage(name: String ,_ completion: @escaping (SVGImageView)->Void) {
        Observable.just(name)
            .map{"https://ghchart.rshah.org/\($0)"}
            .map{URL(string: $0)}
            .filter{$0 != nil}
            .map{ $0!}
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .map{SVGImageView.init(contentsOf: $0)}
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { image in
                image.frame = self.view.bounds
                image.contentMode = .scaleAspectFit
                completion(image)
            })
            .disposed(by: disposedBag)
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
        if NetworkMonitor.shared.isConnected{
            if !repositoryNames.isEmpty{
                repositoryNames.removeAll()
                repositoryValues.removeAll()
                repositoryChartView.clear()
            }
            if !language.isEmpty{
                language.removeAll()
                languageValue.removeAll()
                languagePieChartView.clear()
            }
            self.loginManager.commitToDict()
            print("repoTotal : \(self.loginManager.repoTotal)")
            setLineChartView()
            repositorySetData()
            languageSetData()
            setPieChartView()
            
            initRefresh()
            print("subViewCounts : \(contributionStackView.arrangedSubviews.count)")
//            if contributionStackView.arrangedSubviews.count < 2{
//                getContributionSvgImageFile()
//            }
            getContributionSvgImage(name: self.loginManager.user.name) { svgImage in
                
                if self.contributionStackView.arrangedSubviews.count >= 2{
                    self.contributionStackView.removeArrangedSubview(svgImage)
                }else {
                    self.contributionStackView.addArrangedSubview(svgImage)
                }
            }
            self.refresh.endRefreshing() //새로고침종료
        }else{
            moveDisConnected()
        }
    }
    
    func moveDisConnected(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let disConnectedVC = storyboard.instantiateViewController(withIdentifier: "DisConnectedViewController")
        disConnectedVC.modalPresentationStyle = .fullScreen
        disConnectedVC.modalTransitionStyle = .crossDissolve
        self.present(disConnectedVC, animated: false, completion: nil)
    }
}

//MARK: -AutoLayout
extension ChartViewController {
    
}


//MARK: -차트관련
extension ChartViewController {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    //레포지토리 꺽은선 그래프
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
        set1.circleColors = [NSUIColor.init(rgb: 0x369F36)]
        set1.circleRadius = 5.0
        //그래프 안쪽 원 크기와 색상
        set1.circleHoleColor = UIColor.white
        set1.circleHoleRadius = 4.0
        //        set1.mode = .cubicBezier //선 유연하게
        set1.setColor(UIColor(rgb: 0x65CD3C))//선의 색깔
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
            let coloTop = UIColor(rgb: 0x3FE87F).cgColor
            let colorBottom = UIColor(rgb: 0x78EFAD).cgColor
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
        if sorted.count > 4{
            for i in 0...4{
                self.repositoryNames.append(sorted[i].key)
            }
        }else {
            for i in 0..<sorted.count{
                self.repositoryNames.append(sorted[i].key)
            }
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
        
        repositoryChartView.setExtraOffsets(left: 30, top: 0, right: 30, bottom: 0)
        repositoryChartView.fitScreen()
        //        repositoryChartView.layer.borderWidth = 2
        //        repositoryChartView.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
        //
        
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
        xAxis.granularity = 1
        xAxis.gridColor = .clear
        xAxis.granularityEnabled = true
        
        //        xAxis.labelFont = .boldSystemFont(ofSize: 5) //x축 폰트 설정
        xAxis.labelFont = UIFont(name: "BM EULJIRO", size: 6)!
        xAxis.avoidFirstLastClippingEnabled = false
        
        //        repositoryChartView.data?.setDrawValues(false)
        xAxis.labelTextColor = .black //x축 글자색깔
        xAxis.axisLineColor = .clear //x축 눈금선의 색을 설정
        
        
        
        repositoryChartView.doubleTapToZoomEnabled = false
        repositoryChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)//애니메이션 설정
        
    }
    
    
    //        yAxis.labelFont = .boldSystemFont(ofSize: 12) //왼쪽 y축 눈금의 폰트를 설정
    
    
    
    //MARK: - 언어 원형그래프
    func languageSetData(){
        setLanguageDict()
        
        let sortedDict = languageDict.sorted(by: {$0.value > $1.value})
//        language.append("C++")
//        languageValue.append(5)
        for (key, value) in sortedDict{
            if language.count > 4{
                break
            }
            if key != "Null"{
                language.append(key)
                languageValue.append(value)
            }
            
        }
        if language.isEmpty{
            language.append("Null")
            languageValue.append(1)
        }
        
        var entries = [PieChartDataEntry]()
        for (index, value) in languageValue.enumerated() {
            let entry = PieChartDataEntry(value: Double(value), label: "\(language[index])", data: value)
            entries.append(entry)
        }
        
        let set2 = PieChartDataSet(entries: entries)
        set2.sliceSpace = 2.0
        set2.entryLabelFont = UIFont(name: "BM EULJIRO", size: 12)!
        set2.entryLabelColor = UIColor.black
        set2.yValuePosition = .outsideSlice
        set2.xValuePosition = .insideSlice
        
        var colors: [UIColor] = []
        colors.append(UIColor(red: 237, green: 234, blue: 215))
        colors.append(UIColor(red: 232, green: 194, blue: 192))
        colors.append(UIColor(red: 147, green: 136, blue: 140))
        colors.append(UIColor(red: 51, green: 52, blue: 57))
        colors.append(UIColor(red: 72, green: 94, blue: 108))
        set2.colors = colors
        
        let data = PieChartData(dataSet: set2)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        formatter.percentSymbol = "%"
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        
        data.setValueTextColor(UIColor.black)
        data.setValueFont(UIFont(name: "BM EULJIRO", size: 11)!) //퍼센트글씨체
        data.setDrawValues(true)
        languagePieChartView.data = data
        
        
        
    }
    
    func setPieChartView(){
        //오른쪽아래에 설명적는코드
        //        let d = Description()
        //        d.text = ""
        //        languagePieChartView.chartDescription = d
        
        let normalFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 13)!]
        let languageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemTeal, NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 13)!]
        let partOne = NSMutableAttributedString(string: "가장 많이 사용하신 언어는 ", attributes: normalFontAttributes)
        let combination = NSMutableAttributedString()
        combination.append(partOne)
        
//        let sort = languageDict.sorted {
//            $0.value > $1.value
//        }
        print("languageFirst : \(language.first!)")
        if let first = language.first {
            let partTwo = NSMutableAttributedString(string: "\(first)", attributes: languageAttributes)
            combination.append(partTwo)
        }else {
            let partTwo = NSMutableAttributedString(string: "????", attributes: languageAttributes)
            combination.append(partTwo)
        }
        let partThree = NSMutableAttributedString(string: " 입니다.", attributes: normalFontAttributes)
        combination.append(partThree)
        
        languagePieChartView.centerAttributedText = combination
        languagePieChartView.drawCenterTextEnabled = true
        
        languagePieChartView.transparentCircleColor = UIColor.white //가운데구멍 겉에 색상
        languagePieChartView.transparentCircleRadiusPercent = 0
        languagePieChartView.usePercentValuesEnabled = true
        languagePieChartView.drawSlicesUnderHoleEnabled = false
        languagePieChartView.holeRadiusPercent = 0.40 //가운데구멍크기
        
        languagePieChartView.drawHoleEnabled = true
        languagePieChartView.rotationAngle = 90.0
        languagePieChartView.rotationEnabled = true
        languagePieChartView.highlightPerTapEnabled = false
        
        //모서리둥글게
        languagePieChartView.backgroundColor = .white
        languagePieChartView.layer.cornerRadius = 20
        languagePieChartView.layer.masksToBounds = true
        
        languagePieChartView.legend.enabled = false
        
        
        languagePieChartView.animate(yAxisDuration: 1.7, easingOption: .easeInBack)
        
        
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
