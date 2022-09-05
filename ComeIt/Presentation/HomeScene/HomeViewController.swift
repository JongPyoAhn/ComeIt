//
//  HomeViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit
import Moya
import Combine

class HomeViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var repositoryName: UITextField!
    @IBOutlet weak var commitCountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repositoryPicker: UITextField!
    @IBOutlet weak var levelImage: UIImageView!

    private var latestDayOfCommit = 0
    private var defaultRowIndex: Int = 0
    
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
    
    //커밋 0번이면 노티키고 1번이상이면 노티끄기위해서.
    let userNotification = UNUserNotificationCenter.current()
    let networkMonitor = NetworkMonitor.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createPickerView()
        self.dismissPickerView()
        self.commitTextChange(self.pickerDefaultSetting())
    }
  

    
    func setNavigationTitle(){
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        //픽커뷰에서 안돼고 텍스트필드에 적용하니까 된다.
        repositoryPicker.resignFirstResponder()
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
        commitTextChange(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
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
    
    //커밋횟수 가져오고 UI에 표현
    func commitTextChange(_ row: Int){
        guard let user = user else {return}
        let confirm: () = GithubController.fetchCommit(user.name, repositories[row].name)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion{
                case .finished:
                    print("HomeViewController - fetchCommit : Finished")
                case .failure(let err):
                    print("HomeViewController - fetchCommit : \(err)")
                }
            } receiveValue: {[weak self] commits in
                guard let self = self else {return}
                if let commitLast = commits.last{
                    //오늘 커밋한 횟수
                    self.latestDayOfCommit = commitLast.days[self.dayOfWeekInt - 1]
                    self.commitCountLabel.text = "\(self.latestDayOfCommit)번!!"
                    self.alertOnOff()
                    //0번이면 노티에 현재있는 알람들 isOn = true해주고
                    //1번이상이면 노티에 현재있는 알람들 isOn = false
                    if self.latestDayOfCommit >= 1{
                        //오늘 커밋여부를 알고 알림하기위해 저장.
                        UserDefaults.standard.set(true, forKey: "isCommit")
                        self.commentLabel.text = "😍성공하셨습니다😍"
                    }else{
                       
                        UserDefaults.standard.set(false, forKey: "isCommit")
                        self.commentLabel.text = "🥺오늘은 안하실건가요?🥺"
                    }
                }
            }
            .store(in: &subscription)
        if confirm == () {
            self.commitCountLabel.text = "없음"
            self.commentLabel.text = "😔커밋하신적이 없습니다😔"
        }
    }
    
    func alertOnOff(){
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
        if self.latestDayOfCommit >= 1 {
            for i in 0..<alerts.count{
                self.userNotification.removePendingNotificationRequests(withIdentifiers: [alerts[i].id])
            }
        }else{
            for i in 0..<alerts.count{
                self.userNotification.addNotificaionRequest(by: alerts[i])
            }
        }
    }
    
    
    
    //피커뷰 디폴트값 세팅
    func pickerDefaultSetting() -> Int{
        if let defaults = UserDefaults.standard.string(forKey: "currentSelectedRepository"){
            let names = viewModel.repositoriesNames
            if let defaultRowIndex = names.firstIndex(of: defaults){
                self.defaultRowIndex = defaultRowIndex
            }
            pickerView.selectRow(defaultRowIndex, inComponent: 0, animated: true)
            repositoryName.text = defaults
            repositoryName.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            return defaultRowIndex
        }
        else {
            return 0
        }
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
}
//MARK: -- Binding
extension HomeViewController{
    func bindingUI(){
        viewModel.repositoriesPublisher
            .sink { repositories in
                self.repositories = repositories
            }
            .store(in: &subscription)
        viewModel.userPublisher
            .sink { user in
                self.user = user
            }
            .store(in: &subscription)
        viewModel.getNowDay()
            .sink { dayOfWeek in
                self.dayOfWeekInt = Int(String(dayOfWeek))!
            }
            .store(in: &subscription)
    }
}
