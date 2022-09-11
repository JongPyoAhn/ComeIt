//
//  HomeViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit
import Moya
import Combine
import CombineCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var repositoryName: UITextField!
    @IBOutlet weak var commitCountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repositoryPicker: UITextField!
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var moveToProfileButton: UIButton!
    
    
    private let pickerView = UIPickerView()
    private var repositories: [Repository] = []
    private var user: User?
    private var viewModel: HomeViewModel!
    private var subscription = Set<AnyCancellable>()
    private var dayOfWeekInt: Int = 0
    
    //user랑 repositories는 coordinator -> viewModel로 받아야됨.
    init?(viewModel: HomeViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createPickerView()
        self.dismissPickerView()
        self.viewModel.commitTextChange(self.getRepositoryIndex())
    }
}

//MARK: - 피커뷰 정의
extension HomeViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.repositoriesCount
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.repositoriesNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repositoryPicker.text = viewModel.repositoriesNames[row]
        //유저가 피커뷰에 설정해놓은 값 저장
        UserDefaults.standard.set(viewModel.repositoriesNames[row], forKey: "currentSelectedRepository")
        //선택한 레포지토리의 정보를 가지고와서 몇번 커밋했는지 나타내줄거임.
        self.viewModel.commitTextChange(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    
}
//MARK: -- UI
extension HomeViewController{
    func configureUI(){
        setNavigationTitle()
        repositoryPicker.tintColor = .clear
        repositoryPicker.layer.cornerRadius = 8.0
        repositoryPicker.layer.borderWidth = 0.8
        repositoryPicker.layer.masksToBounds = true
        self.navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = true
    }
    
    func setNavigationTitle(){
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        repositoryPicker.resignFirstResponder()
    }
    
    func createPickerView(){
        pickerView.delegate = self
        repositoryPicker.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.selectButtonTapped))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        repositoryPicker.inputAccessoryView = toolBar
    }
    
    @objc func selectButtonTapped(){
        self.view.endEditing(true) //pickerView 사라지게.
    }
}
//MARK: -- Binding
extension HomeViewController{
    func bindingUI(){
        self.moveToProfileButton.tapPublisher
            .print()
            .sink { _ in
                self.viewModel.profileButtonDidTapped()
            }
            .store(in: &subscription)
        
        viewModel.repositoriesPublisher
            .sink {[weak self] repositories in
                self?.repositories = repositories
            }
            .store(in: &subscription)
        
        viewModel.userPublisher
            .sink {[weak self] user in
                self?.user = user
            }
            .store(in: &subscription)
        
        viewModel.getNowDay()
            .sink {[weak self] dayOfWeek in
                self?.dayOfWeekInt = Int(String(dayOfWeek))!
            }
            .store(in: &subscription)
        
        viewModel.defaultSelectedRepositoryNameRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] selectedRepositoryName in
                self?.repositoryName.text = selectedRepositoryName
                self?.repositoryName.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            }
            .store(in: &subscription)
        
        viewModel.defaultIndexOfSelectedRepositoryRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] index in
                self?.pickerView.selectRow(index, inComponent: 0, animated: true)
            }
            .store(in: &subscription)
        
        viewModel.commitLastRequested
            .receive(on: DispatchQueue.main)
            .sink {[weak self] commitLast in
                guard let self = self else {return}
                //오늘 커밋한 횟수
                let latestDayOfCommit = self.viewModel.getLatestDayOfCommitCount(commitLast, self.dayOfWeekInt)
                self.commitCountLabel.text = "\(latestDayOfCommit)번!!"
                self.viewModel.alertOnOff(latestDayOfCommit)
                //0번이면 노티에 현재있는 알람들 isOn = true해주고
                //1번이상이면 노티에 현재있는 알람들 isOn = false
                if latestDayOfCommit >= 1{
                    //오늘 커밋여부를 알고 알림하기위해 저장.
                    UserDefaults.standard.set(true, forKey: "isCommit")
                    self.commentLabel.text = "😍성공하셨습니다😍"
                }else if commitLast.total != 0{
                    UserDefaults.standard.set(false, forKey: "isCommit")
                    self.commentLabel.text = "🥺오늘은 안하실건가요?🥺"
                }else if commitLast.total == 0{
                    self.commitCountLabel.text = "없음"
                    self.commentLabel.text = "😔이번주에 커밋하신적이 없습니다😔"
                }
            }
            .store(in: &subscription)
    }
}
//MARK: -- Function
extension HomeViewController{
    func getRepositoryIndex() -> Int{
        return viewModel.getDefaultIndexOfSelectedRepository(viewModel.getDefaultSelectedRepositoryName())
    }
}
