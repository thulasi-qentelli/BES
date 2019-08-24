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
        
        
    }
}
