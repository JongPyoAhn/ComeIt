//
//  AlarmTableViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/11.
//

import UIKit
import UserNotifications

class AlarmTableViewController: UITableViewController {

    var alerts: [Alert] = []
    let userNotification = UNUserNotificationCenter.current()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "AlarmTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "AlarmTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alerts = alertList()
    }

    @IBAction func addAlertAction(_ sender: Any) {
        guard let addAlertVC = storyboard?.instantiateViewController(identifier: "AddAlertViewController") as? AddAlertViewController else {return}
        addAlertVC.pickedDate = {[weak self] date in
            guard let self = self else {return}
            
            var alertList = self.alertList()
            print(self.alertList())
           
            
            let newAlert = Alert(date: date, isOn: true)
            
            alertList.append(newAlert)
            alertList.sort{$0.date < $1.date}
            
            self.alerts = alertList
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey:  "alerts")
            
            //오늘커밋데이터가져와서 커밋이 1이상이면 isCommit은 true 1 미만이면 isCommit은 false
            self.userNotification.addNotificaionRequest(by: newAlert)
            
            self.tableView.reloadData()
            
        }
        self.present(addAlertVC, animated: true, completion: nil)
    }
    
    
    func alertList() -> [Alert] {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return []}
        return alerts
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
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts")
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            return
        default:
            break
        }
    }
}

