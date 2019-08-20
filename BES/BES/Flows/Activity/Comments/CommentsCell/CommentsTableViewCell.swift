//
//  CommentsTableViewCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 02/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var txtBody : UITextView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.containerView.layer.cornerRadius = 5
        self.containerView.clipsToBounds = true
    }

    func configure(with comment:Comment){
        
        if let name = comment.userName{
            lblName.text = name
        }else{
            lblName.text = ""
        }
        
        if let updatedDate = comment.updatedDate {
            lblTime.text = self.calculateTimeDifference(updatedDate)
        }else{
            lblTime.text = ""
        }
        
        if let feedContent = comment.comment{
            txtBody.text = feedContent
        }else{
            txtBody.text = ""
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
    
}
