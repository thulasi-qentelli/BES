//
//  CategoryModel.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 27/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import ObjectMapper

class Category: NSObject, Mappable, Codable {
    
    var id: Int?
    var service: String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        service <- map["service"]
    }
}
