//
//  LocationTableCell.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 25/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class LocationTableCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var regionLbl: UILabel!
    @IBOutlet weak var servicesLbl: UILabel!
    @IBOutlet weak var basinLbl: UILabel!
    
    var location:Location = Location()
    var phoneAction:(Location)-> Void = { location  in
    }
    var locationAction:(Location)->Void = { location in
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(loc:Location) {
        self.location = loc
        self.titleLbl.text = location.getTitle()
        self.addressLbl.text = location.getAddress()
        self.phoneLbl.text = location.phone
        self.regionLbl.text = location.region
        self.servicesLbl.text = location.services
        self.basinLbl.text = location.basins
    }
    
    @IBAction func phoneBtnAction(_ sender: UIButton) {
        phoneAction(location)
    }
    
    @IBAction func locationBtnAction(_ sender: UIButton) {
        locationAction(location)
    }
    
}
