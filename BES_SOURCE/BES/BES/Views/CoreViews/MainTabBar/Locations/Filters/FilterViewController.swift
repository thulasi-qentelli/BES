//
//  FilterViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 25/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var acrollView: UIScrollView!
    var locations:[Location] = []
    var regions:[String] = []
    var services:[String] = []
    var basins : [String] = []
    
    var filteredRegions:[String] = []
    var filteredServices:[String] = []
    var filteredBasins : [String] = []
    
    var getFilteredLocations:([Location],[String],[String],[String])->Void = { (loc,filReg,filSer,filBas) in
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for location in locations {
            if let region = location.region, let kServices = location.services, let kBasins = location.basins {
                regions.append(region)
                
                let splittedServices = kServices.components(separatedBy: ",")
                let trimmedServices = splittedServices.map { $0.trimmingCharacters(in: .whitespaces) }
                
                for service in trimmedServices {
                    services.append(service)
                }
                
                let splittedBasins = kBasins.components(separatedBy: ",")
                let trimmedBasins = splittedBasins.map { $0.trimmingCharacters(in: .whitespaces) }
                
                for basin in trimmedBasins {
                    basins.append(basin)
                }
                
                regions = Array(Set(regions))
                services = Array(Set(services))
                basins = Array(Set(basins))
                
                regions.sort(){$0 < $1}
                services.sort(){$0 < $1}
                basins.sort(){$0 < $1}
            }
        }
        
     
        setupFiltersUI()
    }
    
    
    func setupFiltersUI() {
        
        self.acrollView.subviews.map { $0.removeFromSuperview }
        
        let titleLabel1 = UILabel(frame: CGRect(x: 30, y: 20, width: UIScreen.main.bounds.size.width - 60, height: 40))
        titleLabel1.text = "All Regions"
        titleLabel1.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel1.backgroundColor = UIColor.clear
        self.acrollView.addSubview(titleLabel1)
        
        let chipView1 =  ChipFilterView(frame: CGRect(x: 30, y: 80, width: self.view.frame.size.width - 60, height: 800))
        let height1 = chipView1.setupFilters(filters: regions,selectedFil:filteredRegions,rearrange: true,stretch: true)
        self.acrollView.addSubview(chipView1)
        chipView1.frame = CGRect(x: 30, y: 80, width: self.view.frame.size.width - 60, height: height1)
        
        var yPos = 80 + height1 + 20
        
        let titleLabel2 = UILabel(frame: CGRect(x: 30, y: yPos, width: UIScreen.main.bounds.size.width - 60, height: 40))
        titleLabel2.text = "All Services"
        titleLabel2.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel2.backgroundColor = UIColor.clear
        self.acrollView.addSubview(titleLabel2)
        
        yPos = yPos + 80
        
        let chipView2 =  ChipFilterView(frame: CGRect(x: 30, y: yPos, width: self.view.frame.size.width - 60, height: 800))
        let height2 = chipView2.setupFilters(filters: services,selectedFil:filteredServices,rearrange: true,stretch: true)
        self.acrollView.addSubview(chipView2)
        chipView2.frame = CGRect(x: 30, y: yPos, width: self.view.frame.size.width - 60, height: height2)
        
        yPos = yPos + height2 + 20
        
        let titleLabel3 = UILabel(frame: CGRect(x: 30, y: yPos, width: UIScreen.main.bounds.size.width - 60, height: 40))
        titleLabel3.text = "All Basins"
        titleLabel3.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel3.backgroundColor = UIColor.clear
        self.acrollView.addSubview(titleLabel3)
        
        yPos = yPos + 80
        
        let chipView3 =  ChipFilterView(frame: CGRect(x: 30, y: yPos, width: self.view.frame.size.width - 60, height: 800))
        let height3 = chipView3.setupFilters(filters: basins,selectedFil:filteredBasins,rearrange: true,stretch: true)
        self.acrollView.addSubview(chipView3)
        chipView3.frame = CGRect(x: 30, y: yPos, width: self.view.frame.size.width - 60, height: height3)
        
        yPos = yPos + height3 + 80
        
        self.acrollView.contentSize = CGSize(width: self.view.frame.size.width, height: yPos)
        
        chipView1.getFilters = { selectedRegions in
            self.filteredRegions = selectedRegions
        }
        
        chipView2.getFilters = { selectedServices in
            self.filteredServices = selectedServices
        }
        
        chipView3.getFilters = { selectedBasins in
            self.filteredBasins = selectedBasins
        }
    }

    @IBAction func closeBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyBtnAction(_ sender: Any) {
        filterLocations()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearAllBtnAction(_ sender: Any) {
        filteredRegions = []
        filteredServices = []
        filteredBasins = []
        setupFiltersUI()
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func filterLocations() {
        
        var filteredLocations = locations.filter({
            $0.regionsArray.contains(where: {filteredRegions.contains($0)}) ||
                $0.servicesArraay.contains(where: {filteredServices.contains($0)}) ||
                $0.basinsArray.contains(where: {filteredBasins.contains($0)})
        })
        
        if filteredRegions.count == 0 && filteredServices.count == 0 && filteredBasins.count == 0 {
            filteredLocations = locations
        }
        getFilteredLocations(filteredLocations, filteredRegions, filteredServices, filteredBasins)
    }
    
    
}
