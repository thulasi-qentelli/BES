//
//  FilterTableViewCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        self.accessoryType = .none
        self.lblName.textColor = UIColor.black
    }

    func configureWith(_ name:String,isSelected:Bool){
        
        lblName.text = name
        
        if isSelected{
            self.accessoryType = .checkmark
            self.lblName.textColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        }else{
            self.accessoryType = .none
            self.lblName.textColor = UIColor.black
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.accessoryType = .none
        self.lblName.textColor = UIColor.black
    }
    
    
}
