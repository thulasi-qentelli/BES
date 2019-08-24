//
//  FeedTableCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import SDWebImage

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile : UIImageView!
    @IBOutlet weak var txtBodyHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var txtBody : ReadMoreTextView!
    @IBOutlet weak var imgBody : UIImageView!
    @IBOutlet weak var lblCommmentsLike : UILabel!
    @IBOutlet weak var btnLike : UIButton!
    @IBOutlet weak var btnComment : UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isExpanded = false
    @IBOutlet weak var containerView : UIView!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 5
        self.containerView.clipsToBounds = true
        
        imgProfile.image = UIImage(named: "default_profile")
        imgProfile.layer.cornerRadius = imgProfile.frame.width/2
        imgProfile.clipsToBounds = true
        
        imgProfile.layer.borderWidth = 0.5
        imgProfile.layer.borderColor = UIColor(red:0.13, green:0.13, blue:0.22, alpha:0.2).cgColor
        
        imgBody.isHidden = false
        
        txtBody.shouldTrim = true
        txtBody.maximumNumberOfLines = 4
        txtBody.attributedReadMoreText = NSAttributedString(string: "... Read more")
        txtBody.attributedReadLessText = NSAttributedString(string: "..")
        
        if isExpanded{
            txtBody.shouldTrim = false
        }else{
            txtBody.shouldTrim = true
            txtBody.maximumNumberOfLines = 2
            txtBody.attributedReadMoreText = NSAttributedString(string: "... Read more")
            txtBody.attributedReadLessText = NSAttributedString(string: "..")
        }
    }
    

    func configure(with feedDetails:Feed,textViewHeight:CGFloat){
        
        
        if let username = feedDetails.userName{
            lblName.text = username
        }else{
            lblName.text = ""
        }
        
        if let feedContent = feedDetails.content{
            txtBody.text = feedContent
        }else{
            txtBody.text = ""
        }
            
        if let updatedDate = feedDetails.updatedDate {
            lblTime.text = self.calculateTimeDifference(updatedDate)
        }else{
            lblTime.text = ""
        }
        
        var countText = ""
        
        if let comments = feedDetails.comments{
            if comments.count != 0{
                countText = comments.count == 1 ? "1 comment" : "\(comments.count) comments"
            }
        }
        
        if let numberOfLikes = feedDetails.likecount{
            if numberOfLikes != 0{
                if countText != ""{
                    countText = countText + ( numberOfLikes == 1 ? " | 1 like" : " | \(numberOfLikes) likes")
                }else{
                    countText =  ( numberOfLikes == 1 ? " 1 like" : "\(numberOfLikes) likes")
                }
            }
        }
        
        lblCommmentsLike.text = countText
        
        imgBody.isHidden = true
        if let unwrappedImage = feedDetails.image {
            if !unwrappedImage.isEmpty{
                let urlString = unwrappedImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let url  = URL(string: urlString!){
                    self.imgBody.isHidden = false
                    self.imgBody.sd_setImage(with:url, completed: nil)
                }
            }
        }else{
            imgBody.isHidden = true
        }
        
        imgProfile.image = UIImage(named: "default_profile")
        if let unwrappedUserImage = feedDetails.userPic {
            let urlString = unwrappedUserImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url  = URL(string: urlString!){
                self.imgProfile.sd_setImage(with:url, completed: nil)
            }
        }else{
            imgProfile.image = UIImage(named: "default_profile")
        }
        
//        if let userHasLiked = feedDetails.userHasLiked{
//            if userHasLiked{
//                self.btnLike.setImage(UIImage(named: "activity_like_active"), for: .normal)
//            }else{
//                self.btnLike.setImage(UIImage(named: "activity_like"), for: .normal)
//            }
//        }
        
        if isExpanded{
            self.txtBodyHeightConstraint.constant = textViewHeight+20
            txtBody.shouldTrim = false
        }else{
            self.txtBodyHeightConstraint.constant = 80
            txtBody.shouldTrim = true
        }
    }
    
    func getDate(from inputString:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: inputString) // replace Date String
    }
    
    func calculateTimeDifference(_ referenceDate : String) -> String {
        let postedDate = getDate(from: referenceDate)
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(postedDate!)
        
        if timeDifference < 60{
            return "just now"
        }
        
        let numberOfMinutes = Int(timeDifference/60)
        if numberOfMinutes < 60{
            return "\(numberOfMinutes)m ago"
        }
        
        let numberOfHours = Int(numberOfMinutes/60)
        if numberOfHours < 24{
            if numberOfHours == 1{
                return "\(numberOfHours) Hour ago"
            }
            return "\(numberOfHours) Hours ago"
        }
        
        let numberOfDays = Int(numberOfHours/24)
        if numberOfDays < 30{
            if Int(numberOfDays) == 1{
                return "\(numberOfDays) Day ago"
            }
            return "\(numberOfDays) Days ago"
        }
        
        let numberOfMonths = Int(numberOfDays/30)
        if numberOfMonths < 12{
            if numberOfMonths == 1{
                return "\(numberOfMonths) Month ago"
            }
            return "\(numberOfMonths) Months ago"
        }
        
        let numberOfYears = Int(numberOfMonths/12)
        if numberOfYears < 100{
            if numberOfYears == 1{
                return "\(numberOfYears) Year ago"
            }
            return "\(numberOfYears) Years ago"
        }
        
        return " "
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgBody.isHidden = false
        imgProfile.image = nil
        
        txtBody.shouldTrim = true
        txtBody.maximumNumberOfLines = 4
        txtBody.attributedReadMoreText = NSAttributedString(string: "... Read more")
        txtBody.attributedReadLessText = NSAttributedString(string: "..")
        self.isExpanded = false

    }
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
