//
//  ExpandedLocationTableViewCell.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class ExpandedLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var lblRegion : UILabel!
    @IBOutlet weak var lblAddress : UILabel!
   
    @IBOutlet weak var btnPhoneNumber: UIButton!
    
    @IBOutlet weak var lblService1 : UILabel!
    @IBOutlet weak var lblService2 : UILabel!
    @IBOutlet weak var lblService3 : UILabel!
    @IBOutlet weak var lblService4 : UILabel!
    
    @IBOutlet weak var lblRe : UILabel!
    @IBOutlet weak var lblBasins : UILabel!
    @IBOutlet weak var btnCollapse : UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true
        
        lblService1.layer.cornerRadius = 14.5
        lblService1.layer.borderColor = UIColor(red:1, green:0.49, blue:0.6, alpha:1).cgColor
        lblService1.layer.borderWidth = 0.5
        
        lblService2.layer.cornerRadius = 14.5
        lblService2.layer.borderColor = UIColor(red:0.87, green:0.62, blue:0.9, alpha:1).cgColor
        lblService2.layer.borderWidth = 0.5
        
        lblService3.layer.cornerRadius = 14.5
        lblService3.textColor = UIColor(red:1, green:0.49, blue:0.6, alpha:1)
        lblService3.layer.borderColor = UIColor(red:1, green:0.49, blue:0.6, alpha:1).cgColor
        lblService3.layer.borderWidth = 0.5
        
        lblService4.layer.cornerRadius = 14.5
        lblService4.textColor = UIColor(red:0.52, green:0.87, blue:0.85, alpha:1)
        lblService4.layer.borderColor = UIColor(red:0.52, green:0.87, blue:0.85, alpha:1).cgColor
        lblService4.layer.borderWidth = 0.5
        
        unhideViews()
    }
    
    func unhideViews(){
        
        lblService1.isHidden = false
        lblService2.isHidden = false
        lblService3.isHidden = false
        lblService4.isHidden = false
    }
    
    func configureWith(_ location:Location){
        
        unhideViews()
        
        var totalAddress = ""
        var cityName = ""
        
        if let street = location.street{
            totalAddress = street
        }
        
        if let city = location.city{
            totalAddress = totalAddress+" , "+city
            cityName = city
        }
        
        if let state = location.state{
            totalAddress = totalAddress+" , "+state
            cityName = cityName+" , "+state
        }
        
        if let zip = location.zip{
            totalAddress = totalAddress+" "+zip
        }
        
        lblRegion.text = cityName
        lblAddress.text = totalAddress
        
        if let phoneNumber = location.phone{
            btnPhoneNumber.setTitle(phoneNumber, for: .normal)
        }else{
            btnPhoneNumber.setTitle("", for: .normal)
        }
        
        if let services = location.services{
            let components = services.components(separatedBy: ",")
            
            if components.count == 1{
                lblService1.text = components.first!
                lblService2.isHidden = true
                lblService3.isHidden = true
                lblService4.isHidden = true
            }
            
            if components.count == 2{
                lblService1.text = components.first!
                lblService2.text = components.last!
                lblService3.isHidden = true
                lblService4.isHidden = true
            }
            
            if components.count == 3{
                lblService1.text = components.first!
                lblService2.text = components[1]
                lblService3.text = components[2]
                lblService4.isHidden = true
            }
            
            if components.count > 3{
                lblService1.text = components.first!
                lblService2.text = components[1]
                lblService3.text = components[2]
                lblService4.text = components[3]
            }
        }
        
        if let region = location.region{
            lblRe.text = region
        }
        
        if let basins = location.basins{
            lblBasins.text = basins
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        unhideViews()
    }
}
