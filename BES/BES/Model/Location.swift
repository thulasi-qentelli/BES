//
//  Location.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//
import Foundation

struct Location: Codable {
    let id: Int?
    let region, phone,state,city,street,zip,services, basins, createdDate, updatedDate: String?
    let latitude,longitude:String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        region = try values.decodeIfPresent(String.self, forKey: .region)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        state = try values.decodeIfPresent(String.self, forKey: .state)
        street = try values.decodeIfPresent(String.self, forKey: .street)
        zip = try values.decodeIfPresent(String.self, forKey: .zip)
        services = try values.decodeIfPresent(String.self, forKey: .services)
        basins = try values.decodeIfPresent(String.self, forKey: .basins)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
    }
}
