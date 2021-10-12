//
//  AlarmTableViewCell.swift
//  Gitramy
//
//  Created by 안종표 on 2021/10/11.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var meridiumLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
