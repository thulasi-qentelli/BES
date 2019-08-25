//
//  FeedTableViewCell.swift
//  Layout
//
//  Created by Thulasi Ram Boddu on 25/08/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileImgPlaceholderView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    
    var readMoreFunction:(UIButton, String)->Void = { (sender, str) in
    
    }
    
    var string = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        getTextForReadmore(numberOfLines: 3)
        profileImgView.layer.cornerRadius = 25
        profileImgView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func readMoreAction(_ sender: UIButton) {
        readMoreFunction(sender, string)
    }
    
    func getTextForReadmore(kStr:String, numberOfLines:Int) {
        
        string = kStr
        self.readMoreBtn.isHidden = false
        var height: CGFloat = 0
        var changes = 0
        var finalArr:[String] = []
        let splitArray = string.split(separator: " ")
        for i in 0..<splitArray.count {
            
            finalArr.append(String(splitArray[i]))
            
            let subStr = finalArr.joined(separator: " ")
            print(subStr)
            let newStr = String(subStr)
            
            let kHeight = newStr.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: self.txtLbl.font)
            
            if height == 0 {
                height = kHeight
            }
            else {
                if height != kHeight {
                    changes = changes + 1
                }
                height = kHeight
            }
            if splitArray.count == finalArr.count {
                    self.txtLbl.text = string
                    self.readMoreBtn.isHidden = true
            }
            else if changes == numberOfLines {
                finalArr.removeLast()
                finalArr.removeLast()
                finalArr.removeLast()
                self.txtLbl.text =  finalArr.joined(separator: " ") + "..."
                break
            }
        }
    }
}
