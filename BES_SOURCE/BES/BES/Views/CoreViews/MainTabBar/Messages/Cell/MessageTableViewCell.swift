//
//  MessageTableViewCell.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var messaageContainer: UIView!
    @IBOutlet weak var timeStampLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImgView.layer.cornerRadius = 21
        self.profileImgView.layer.borderWidth   =   3
        self.profileImgView.layer.borderColor  = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor
        self.profileImgView.layer.masksToBounds =   true
        
        self.messaageContainer.layer.cornerRadius = 4
        self.messaageContainer.layer.masksToBounds =   true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
