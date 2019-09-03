//
//  User.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 30/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

enum CodingKeys: String, CodingKey {
    case alpha
    case red
    case green
    case blue
}


struct User: Codable {
    let id: Int?
    let firstName, lastName, email, password: String?
    let role, pic, createdDate, updatedDate,location,token: String?
    let feeds: [Feed]?
    let isActive: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        pic = try values.decodeIfPresent(String.self, forKey: .pic)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        feeds = try values.decodeIfPresent([Feed].self, forKey: .feeds)
        isActive = try values.decodeIfPresent(Int.self, forKey: .isActive)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        token = try values.decodeIfPresent(String.self, forKey: .token)
    }
}



