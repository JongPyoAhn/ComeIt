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
    var repoNames: [String] = []
    var latestDayOfCommit = 0
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repositoryPicker.tintColor = .clear
        createPickerView()
        dismissPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.levelImage.image = UIImage(named: "브론즈_2")
        //
        loginManager.fetchUser {[weak self] user in
            guard let self = self else {return}
            
            self.nameLabel.text = "\(user.name)님 환영합니다."
            self.companyLabel.text = "소속 : \(user.company)"
            self.numOfRepository.text = "총 레포지토리 수 : \(user.reposPublic + user.reposPrivate)"
            //
            self.loginManager.fetchRepository(user.name) {repositories in
                for i in 0..<repositories.count {
                    self.repoNames.append(repositories[i].name)
                }
            }
            //
            self.userName = user.name
            
        }
        //
        
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
        return repoNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repositoryPicker.text = repoNames[row]
        //선택한 레포지토리의 정보를 가지고와서 몇번 커밋했는지 나타내줄거임.
        self.loginManager.fetchCommit(userName, repoNames[row]) {[weak self] commits in
            guard let self = self else {return}
            
            print(commits.last!)
            self.latestDayOfCommit = commits.last!.days[Int(self.getNowDay())! - 1]
            print(commits.last!.days[Int(self.getNowDay())! - 1])
            print(self.latestDayOfCommit)
            
            self.commitCountLabel.text = "\(self.latestDayOfCommit)번!!"
            if self.latestDayOfCommit >= 1{
                self.commentLabel.text = "😍성공하셨습니다😍"
            }else{
                self.commentLabel.text = "🥺오늘은 안하실건가요?🥺"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    
    func createPickerView(){
        let pickerView = UIPickerView()
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
    //오늘요일수 구하는 함수(1~7) 일,월,화...,토
    func getNowDay() -> String{
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"
        let str = dateFormatter.string(from: nowDate)
        return str
    }
    
}
