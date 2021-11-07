//
//  HomeViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var commitCountLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repositoryPicker: UITextField!
    @IBOutlet weak var numOfRepository: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelImage: UIImageView!
    let loginManager = LoginManager.shared
    var repoNames: [Repository] = []
    var latestDayOfCommit = 0
    var userName = ""

    let pickerView = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        repositoryPicker.tintColor = .clear
        createPickerView()
        dismissPickerView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userName = loginManager.user!.name
        self.levelImage.image = UIImage(named: "브론즈_2")
        loginManager.fetchUser {[weak self] user in //유저정보가져오기
            guard let self = self else {return}
            self.userName = user.name
            self.nameLabel.text = "\(user.name)님 환영합니다."
            self.companyLabel.text = "소속 : \(user.company)"
            self.numOfRepository.text = "총 레포지토리 수 : \(user.reposPublic + user.reposPrivate)"
//            self.loginManager.fetchRepository(user.name) {[weak self]repositories in
//                guard let self = self else {return}
//                self.repoNames = repositories//레포지토리정보가져오기
//            }
            
        }
        loginManager.fetchRepository(userName) {[weak self]repositories in
            guard let self = self else {return}
            self.repoNames = repositories//레포지토리정보가져오기
        }
        
        
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
        return repoNames.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repoNames[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repositoryPicker.text = repoNames[row].name
        //유저가 피커뷰에 설정해놓은 값 저장
        UserDefaults.standard.set(repoNames[row].name, forKey: "currentSelectedRepository")
        
        //선택한 레포지토리의 정보를 가지고와서 몇번 커밋했는지 나타내줄거임.
        self.loginManager.fetchCommit(userName, repoNames[row].name) {[weak self] commits in
            guard let self = self else {return}
            
            print(commits.last!)
            //오늘 요일의 커밋을 정보에서 빼내옴.
            self.latestDayOfCommit = commits.last!.days[Int(self.getNowDay())! - 1]
            print(commits.last!.days[Int(self.getNowDay())! - 1])
            print(self.latestDayOfCommit)
            self.commitTextChange()
        }
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
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.selectButtonTapped))
        toolBar.setItems([button, space], animated: true)
        toolBar.isUserInteractionEnabled = true
        repositoryPicker.inputAccessoryView = toolBar
        
    }
    
    @objc func selectButtonTapped(){
        self.view.endEditing(true) //pickerView 사라지게.
        
    }
    
    func commitTextChange(){
        self.commitCountLabel.text = "\(self.latestDayOfCommit)번!!"
        if self.latestDayOfCommit >= 1{
            self.commentLabel.text = "😍성공하셨습니다😍"
        }else{
            self.commentLabel.text = "🥺오늘은 안하실건가요?🥺"
        }
    }
    
    //오늘요일수 구하는 함수(1~7) 일,월,화...,토
    func getNowDay() -> String{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
    func pickerDefaultSetting(){
        let defaults = UserDefaults.standard.string(forKey: "currentSelectedRepository")!
        print("defaults: \(defaults)")
        let names = repoNames.map{$0.name}
        let defaultRowIndex = names.firstIndex(of: defaults)!
        print("defaultRowIndex : \(defaultRowIndex)")
        pickerView.selectRow(defaultRowIndex, inComponent: repoNames.count, animated: true)
    }
    
}
