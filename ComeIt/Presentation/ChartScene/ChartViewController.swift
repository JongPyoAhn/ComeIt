//
//  TotalViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/04.
//

import UIKit
import Combine

import Kingfisher
import PocketSVG
import Charts
import Moya

class ChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contributionStackView: UIStackView!
    @IBOutlet weak var contributionView: UIView!
    @IBOutlet weak var repositoryChartView: LineChartView!
    @IBOutlet weak var languagePieChartView: PieChartView!
    private let refresh = UIRefreshControl()
    
    private var languageDict = [String: Int]()
    private var chartLanguageNames = [String]()
    private var chartLanguageValues = [Int]()
    private var repositoryCommitCountDict: [String:Int] = [:] //차트에서 사용
    private var repositories: [Repository]?
    private var repositoryNames: [String] = []//x축을 레파지토리 이름 받아오기
    private let pieChartDataEntries: [PieChartDataEntry] = []
    private var repositoryValues: [ChartDataEntry] = [] //모든 레포지토리 데이터 받아와서 y축을 총커밋수
    private var user: User?
    private var viewModel: ChartViewModel!
    
    private var provider: MoyaProvider<GithubAPI>!
    private var subscription = Set<AnyCancellable>()
    
    
    
    init?(viewModel: ChartViewModel,coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
        configureUI()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func configureUI(){
        self.navigationController?.isNavigationBarHidden = true
        setNavigationTitle()
    }
    
    func bindUI(){
        self.viewModel.userPublisher
            .sink { user in
                self.user = user
            }
            .store(in: &subscription)
        
        self.viewModel.repositoriesPublisher
            .sink { repositories in
                self.repositories = repositories
            }
            .store(in: &subscription)
        
        self.viewModel.languageDictRequested
            .sink { languageDict in
                self.languageDict = languageDict
            }
            .store(in: &subscription)
        
        self.viewModel.repositoryCommitCountDictPublisher
            .sink { repositoryCommitCountDict in
                self.repositoryCommitCountDict = repositoryCommitCountDict
            }
            .store(in: &subscription)
        
        self.viewModel.getContributionImageURL()
            .receive(on: DispatchQueue.main)
            .sink { url in
                let svgImageView = SVGImageView.init(contentsOf: url)
                svgImageView.frame = self.view.bounds
                svgImageView.contentMode = .scaleAspectFit
                if self.contributionStackView.arrangedSubviews.count >= 2{
                    self.contributionStackView.removeArrangedSubview(svgImageView)
                }else {
                    self.contributionStackView.addArrangedSubview(svgImageView)
                }
            }
            .store(in: &subscription)
        
        self.viewModel.setLanguageDict()
        self.viewModel.repositoryCommitCountToDictionary()
    }
}

//MARK: -UI
extension ChartViewController{
    func setNavigationTitle(){
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
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
        self.viewModel.setLanguageDict()
        self.viewModel.repositoryCommitCountToDictionary()
        
        if !repositoryNames.isEmpty{
            repositoryNames.removeAll()
            repositoryValues.removeAll()
            repositoryChartView.clear()
        }
        if !chartLanguageNames.isEmpty{
            chartLanguageNames.removeAll()
            chartLanguageValues.removeAll()
            languagePieChartView.clear()
        }
        
        self.setLineChartView()
        self.repositorySetData()
        
        self.languageSetData()
        self.setPieChartView()
        
        self.initRefresh()
        self.refresh.endRefreshing() //새로고침종료
    }
}

//MARK: - 차트관련
extension ChartViewController {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    //MARK: - 레포지토리 꺽은선 그래프
    func repositorySetData(){
        self.repositoryValues = self.viewModel.getLineChartXLabel(self.repositoryNames)
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
        set1.fill = LinearGradientFill(gradient: gradient, angle: 90.0)
//        set1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
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
        let repositoryCommitCountDictSorted = self.viewModel.sortAscendingDictKey(self.viewModel.sortDescendingDictValue(repositoryCommitCountDict))
        
        self.repositoryNames = self.viewModel.repositoryNamesSetting(repositoryCommitCountDictSorted)
        
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
        
        let yAxis = repositoryChartView.leftAxis
        let xAxis = repositoryChartView.xAxis
        yAxis.setLabelCount(repositoryNames.count, force: true) //왼쪽 y축 눈금의 수를 설정
        yAxis.enabled = false
        
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
    
    //MARK: - 언어 원형그래프
    func languageSetData(){
        let sortedDict = self.viewModel.sortDescendingDictValue(languageDict)
        (self.chartLanguageNames, self.chartLanguageValues) = self.viewModel.filterLanguageChartData(sortedDict)
        
        let entries = self.viewModel.getPieChartEntry(self.chartLanguageNames, self.chartLanguageValues)
        
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
        let normalFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 13)!]
        let languageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemTeal, NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 13)!]
        let partOne = NSMutableAttributedString(string: "가장 많이 사용하신 언어는 ", attributes: normalFontAttributes)
        let combination = NSMutableAttributedString()
        combination.append(partOne)

        if let first = chartLanguageNames.first {
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

