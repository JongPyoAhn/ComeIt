//
//  AlarmTableViewController.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/11.
//

import UIKit

class AlarmTableViewController: UITableViewController {

    var alerts: [Alert] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "AlarmTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "AlarmTableViewCell")
    }

    @IBAction func addAlertAction(_ sender: Any) {
        guard let addAlertVC = storyboard?.instantiateViewController(identifier: "AddAlertViewController") as? AddAlertViewController else {return}
        addAlertVC.pickedDate = {[weak self] date in
            guard let self = self else {return}
            
            var alertList = self.alertList()
            
            let newAlert = Alert(date: date, isOn: true)
            
            alertList.append(newAlert)
            alertList.sort{$0.date < $1.date}
            
            self.alerts = alertList
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey:  "alerts")
            
        }
        self.present(addAlertVC, animated: true, completion: nil)
    }
    
    
    func alertList() -> [Alert] {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return []}
        return alerts
    }
}


extension AlarmTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as? AlarmTableViewCell else {return UITableViewCell()}
        cell.toggleSwitch.isOn = alerts[indexPath.row].isOn
        cell.meridiumLabel.text = alerts[indexPath.row].meridium
        cell.timeLabel.text = alerts[indexPath.row].time
        
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
            return
        default:
            break
        }
    }
}
