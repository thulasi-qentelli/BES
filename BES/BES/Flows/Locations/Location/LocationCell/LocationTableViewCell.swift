//
//  LocationTableViewCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 31/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView : UIView!
   @IBOutlet weak var lblRegion : UILabel!
   @IBOutlet weak var btnExpand : UIButton!
    @IBOutlet weak var lblService2: UILabel!
    @IBOutlet weak var lblService1: UILabel!
    @IBOutlet weak var lblEtc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblService1.isHidden = false
        lblService2.isHidden = false
        lblEtc.isHidden = false
        
        backgroundColor = UIColor(red:0.95, green:0.95, blue:0.98, alpha:1)
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        lblService1.layer.cornerRadius = 14.5
        lblService1.layer.borderColor = UIColor(red:1, green:0.49, blue:0.6, alpha:1).cgColor
        lblService1.layer.borderWidth = 0.5
        
        lblService2.layer.cornerRadius = 14.5
        lblService2.layer.borderColor = UIColor(red:0.87, green:0.62, blue:0.9, alpha:1).cgColor
        lblService2.layer.borderWidth = 0.5
    }

    func configure(with location:Location){
        
        var cityName = ""
        if let city = location.city{
            cityName = city
        }
        
        if let state = location.state{
            cityName = cityName+" , "+state
        }
        lblRegion.text = cityName
        
        guard let services = location.services else{
            lblService1.isHidden = true
            lblService2.isHidden = true
            lblEtc.isHidden = true
            return
        }
        
        let serviceNames = services.components(separatedBy: ",")
        guard let firstService = serviceNames.first else{
            lblService1.isHidden = true
            lblService2.isHidden = true
            lblEtc.isHidden = true
            return
        }
        
        lblService1.isHidden = false
        lblService1.text = firstService
        
        guard serviceNames.count > 1 else{
            lblService2.isHidden = true
            lblEtc.isHidden = true
            return
        }
    
        lblService2.isHidden = false
        lblService2.text = serviceNames[1]
        
        guard serviceNames.count > 2 else{
            lblEtc.isHidden = true
            return
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblService1.isHidden = false
        lblService2.isHidden = false
        lblEtc.isHidden = false
    }
}
