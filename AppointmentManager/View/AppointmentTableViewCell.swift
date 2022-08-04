//
//  AppointmentTableViewCell.swift
//  AppointmentManager
//
//  Created by Vishal Bavaliya on 04/08/22.
//

import UIKit

class AppointmentTableViewCell: UITableViewCell {

    @IBOutlet weak var candidateImage: UIImageView!
    @IBOutlet weak var candidateName: UILabel!
    @IBOutlet weak var appointmentTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
