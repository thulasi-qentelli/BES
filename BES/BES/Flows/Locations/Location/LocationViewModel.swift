//
//  LocationViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LocationViewModel{
    
     let defaults = UserDefaults.standard
    let besService = BESService()
    var didGetLocations : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var didFilterOptions : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var locations = [Location]()
    var filteredLocations = [Location]()
    var regions   = [String]()
    var basins   = [String]()
    var services   = [String]()
    
    func getLocations(){
        
        if let savedLocations = self.getSavedLocations(){
            self.locations = savedLocations
            self.didGetLocations.accept(true)
            return
        }
        
        besService.getLocations()
            .done{ locations in
                self.locations = locations
                self.saveLocations()
                self.didGetLocations.accept(true)
            }.catch{ error in
                print(error)
                self.didGetLocations.accept(false)
        }
    }
    
    func getSavedLocations() -> [Location]?{
        
        if let savedLocations = defaults.object(forKey: "SavedLocations") as? Data {
            let decoder = JSONDecoder()
            if let locations = try? decoder.decode([Location].self, from: savedLocations) {
                if locations.isEmpty {return nil}
                else{return locations}
            }
        }
        return nil
    }
    
    func saveLocations(){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.locations) {
            defaults.set(encoded, forKey: "SavedLocations")
        }
    }
    
    func getRegions(){
        
        for location in self.locations{
            if let region = location.region{
                if !self.regions.contains(region){
                     regions.append(region)
                }
            }
        }
        
    }
    
    func getServices(){
        for location in self.locations{
            if let service = location.services{
                let allServices = service.components(separatedBy: ",")
                for each in allServices{
                    let service = each.trimmingCharacters(in: .whitespaces)
                    if !self.services.contains(service){
                        self.services.append(service)
                    }
                }
            }
        }
    }
    
    func getBasins(){
        for location in self.locations{
            if let basin = location.basins{
                let allBasins = basin.components(separatedBy: ",")
                for each in allBasins{
                    if !self.basins.contains(each){
                        self.basins.append(each)
                    }
                }
            }
        }
    }
    
    func filterRegionsWith(region inputRegion:String?,service inputService:String?,basin inputBasin:String?){
        self.filteredLocations.removeAll()
        
            
            if let filterRegion = inputRegion,inputService == nil,inputBasin==nil{
                for location in self.locations{
                    if let region = location.region{
                        if region==filterRegion{
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            if inputRegion == nil,let filterService = inputService,inputBasin==nil{
                for location in self.locations{
                    if let service = location.services{
                        if service.contains(filterService){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            if inputRegion == nil,inputService == nil,let filteredBasin=inputBasin{
                for location in self.locations{
                    if let basin = location.basins{
                        if basin.contains(filteredBasin){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            if let filteredRegion = inputRegion,let filteredService = inputService,inputBasin==nil{
                for location in self.locations{
                    if let region = location.region,let service = location.services{
                        if region==filteredRegion && service.contains(filteredService){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            if let filteredRegion = inputRegion,inputService==nil,let filteredBasin=inputBasin{
                for location in self.locations{
                    if let region = location.region,let basin = location.basins{
                        if region==filteredRegion && basin.contains(filteredBasin){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            if inputRegion==nil,let filteredService = inputService,let filteredBasin=inputBasin{
                for location in self.locations{
                    if let service = location.services,let basin = location.basins{
                        if service.contains(filteredService) && basin.contains(filteredBasin){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
            
            
            if let filteredRegion = inputRegion,let filteredService = inputService,let filteredBasin=inputBasin{
                for location in self.locations{
                    if let region = location.region,let service = location.services,let basin = location.basins{
                        if region==filteredRegion && service.contains(filteredService) && basin.contains(filteredBasin){
                            filteredLocations.append(location)
                        }
                    }
                }
            }
        
        
        if inputRegion == nil,inputService == nil,inputBasin == nil{
            self.filteredLocations = locations
        }
            
        
        self.didFilterOptions.accept(true)
    }
    
    
}

