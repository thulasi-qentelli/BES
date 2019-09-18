//
//  MessageTableViewCell.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import SDWebImage

class MessageTableViewCell1: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var messaageContainer: UIView!
    @IBOutlet weak var timeStampLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    var message:Message?
    
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
    
    
    func setupCell(message:Message) {
        self.message = message
        self.profileImgView.image = nil
        self.nameLbl.text = ""
        if message.isNameRequired {
            self.nameLbl.text = message.userName?.capitalized
            if AppController.shared.colorsDict[message.userName!] == nil {
                AppController.shared.colorsDict[message.userName!] = UIColor.random
            }
            self.nameLbl.textColor = AppController.shared.colorsDict[message.userName!]
        }
        
        self.profileImgView.setGmailTypeImageFromString(str: message.userName?.gmailString ?? " ", bgcolor: AppController.shared.colorsDict[message.userName!] ?? UIColor.black)
        self.messageLbl.text = (message.message ?? "")
        self.timeStampLbl.text = message.createdDate?.date?.displayTime
        
        
        let placeHolderImg = getGmailTypeImageFromString(str: message.userName?.gmailString ?? " ", bgcolor: AppController.shared.colorsDict[message.userName ?? ""] ?? UIColor.black)
        
        if let urlString = message.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                self.profileImgView.sd_setImage(with: url, placeholderImage: placeHolderImg , options:SDWebImageOptions.avoidAutoSetImage, completed: { (image, error, cacheType, url) in
                    DispatchQueue.main.async {
                        if let image = image, let userPic = self.message?.userPic, userPic == url!.absoluteString {
                            self.profileImgView.image = image
                        }
                    }
                })
            }
        }
    }
}
