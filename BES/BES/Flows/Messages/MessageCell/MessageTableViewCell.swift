//
//  MessageTableViewCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 31/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var txtView : UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }

    func configureWith(_ message:Message){
        
        guard let content = message.message else { return }
        
        txtView.text = content
        timeStampLabel.text = ""
        if let userName = message.userName, let createdDate =  message.createdDate {
            let createdDateTime = createdDate.components(separatedBy: " ").last ?? ""
            timeStampLabel.text = "@" + userName + ", " + createdDateTime
        }
    }
    
    func setupView(){
        
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1).cgColor
        txtView.layer.cornerRadius = 12
    }
    
}
