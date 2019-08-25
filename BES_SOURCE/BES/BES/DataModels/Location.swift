//
//  Location.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 23/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import ObjectMapper

class Location: NSObject, Mappable, Codable {
    
    var id: Int?
    var region: String?
    var phone: String?
    var state: String?
    var city: String?
    var street: String?
    var zip: String?
    var services: String?
    var basins: String?
    var latitude: String?
    var longitude: String?
    var createdDate: String?
    var updatedDate: String?
    
    var regionsArray:[String] = []
    var servicesArraay:[String] = []
    var basinsArray:[String] = []
    
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        region <- map["region"]
        phone <- map["phone"]
        state <- map["state"]
        city <- map["city"]
        street <- map["street"]
        zip <- map["zip"]
        services <- map["services"]
        basins <- map["basins"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        updatedDate <- map["updatedDate"]
        updatedDate <- map["updatedDate"]
        
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        
        if let kregion = region, let kServices = services, let kBasins = basins {
            regionsArray.append(kregion)
            let splittedServices = kServices.components(separatedBy: ",")
            let trimmedServices = splittedServices.map { $0.trimmingCharacters(in: .whitespaces) }
            
            for service in trimmedServices {
                servicesArraay.append(service)
            }
            
            let splittedBasins = kBasins.components(separatedBy: ",")
            let trimmedBasins = splittedBasins.map { $0.trimmingCharacters(in: .whitespaces) }
            
            for basin in trimmedBasins {
                basinsArray.append(basin)
            }
        }
        
        
    }
    
    func getTitle() -> String{
        var arr: [String] = []
        if let kcity = city {
            arr.append(kcity)
        }
        if let kstate = state {
            arr.append(kstate)
        }
        
        return arr.joined(separator: ", ")
    }
    func getAddress() -> String{
        var str = ""
        if let kstreet = street {
            str.append("\(kstreet)\n")
        }
        if let kcity = city {
            str.append("\(kcity), ")
        }
        if let kstate = state {
            str.append("\(kstate) ")
        }
        if let kzip = zip {
            str.append(kzip)
        }
        
        return str
    }
}
