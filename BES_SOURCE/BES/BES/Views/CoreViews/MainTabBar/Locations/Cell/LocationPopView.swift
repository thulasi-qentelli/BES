//
//  LocationPopView.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 27/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class LocationPopView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var regionLbl: UILabel!
    @IBOutlet weak var servicesLbl: UILabel!
    @IBOutlet weak var basinLbl: UILabel!
    
    var location:Location?
    
    var phoneAction:(Location)-> Void = { location  in
    }
    var locationAction:(Location)->Void = { location in
        
    }
    
    @IBAction func phoneBtnAction(_ sender: UIButton) {
        if let loc = self.location {
            phoneAction(loc)
        }
    }
    
    @IBAction func locationBtnAction(_ sender: UIButton) {
        if let loc = self.location {
            locationAction(loc)
        }
    }
}
