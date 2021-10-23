//
//  AlarmTableViewCell.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/11.
//

import UIKit
import UserNotifications

class AlarmTableViewCell: UITableViewCell {

    let userNotificaionCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var meridiumLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func alertSwitchValueChanged(_ sender: UISwitch) {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
        
        alerts[sender.tag].isOn = sender.isOn
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
        if sender.isOn {
            userNotificaionCenter.addNotificaionRequest(by: alerts[sender.tag])
        }else {
            userNotificaionCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
        }
        
    }
    
}
