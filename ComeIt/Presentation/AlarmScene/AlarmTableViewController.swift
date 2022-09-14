//
//  AlarmTableViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/11.
//

import UIKit
import UserNotifications
import Combine

import CombineCocoa

class AlarmTableViewController: UITableViewController {

    private var subscription = Set<AnyCancellable>()
    private var viewModel: AlarmViewModel
    
    private var alerts: [Alert] = []
    private let userNotification = UNUserNotificationCenter.current()
    
    @IBOutlet weak var addAlertButton: UIBarButtonItem!
    
    init?(viewModel: AlarmViewModel,coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle()
        configureUI()
        bindUI()
        
        tableView.register(UINib(nibName: "AlarmTableViewCell", bundle: nil), forCellReuseIdentifier: "AlarmTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.alertsOnOffSetting()
        tableView.reloadData()
    }

}
extension AlarmTableViewController: AddAlertViewControllerDelegate{
    func addAlert(_ alert: Alert) {
        self.alerts.append(alert)
        self.alerts.sort{$0.date < $1.date}
        self.viewModel.alertsUserDefaultSetting(self.alerts)
        
        //오늘커밋데이터가져와서 커밋이 1이상이면 isCommit은 true 1 미만이면 isCommit은 false
        if !UserDefaults.standard.bool(forKey: "isCommit"){
            self.userNotification.addNotificaionRequest(by: alert)
        }
        self.tableView.reloadData()
    }

}

extension AlarmTableViewController{
    func configureUI(){
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func bindUI(){
        self.addAlertButton.tapPublisher
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                
                self?.viewModel.addAlertButtonDidTapped()
            }
            .store(in: &subscription)
        
        self.viewModel.alertsPublisher
            .sink { alerts in
                self.alerts = alerts
            }
            .store(in: &subscription)
        
        self.viewModel.alertsUserDefaultLoad()
    }
    
    func setNavigationTitle(){
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "BM EULJIRO", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
    }
}


// MARK: - 테이블뷰 딜리게이트, 데이터소스
extension AlarmTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as? AlarmTableViewCell else {return UITableViewCell()}
        cell.toggleSwitch.isOn = alerts[indexPath.row].isOn
        cell.meridiumLabel.text = alerts[indexPath.row].meridium
        cell.timeLabel.text = alerts[indexPath.row].time
        
        //각각의 인덱스에 있는 스위치의 상태를 알기위함
        cell.toggleSwitch.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            userNotification.removePendingNotificationRequests(withIdentifiers: [alerts[indexPath.row].id])
            alerts.remove(at: indexPath.row)
            self.viewModel.alertsUserDefaultSetting(self.alerts)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            return
        default:
            break
        }
    }
}

