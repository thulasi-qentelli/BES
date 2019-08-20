//
//  Category.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct Category: Codable {
    let id: Int?
    let service: String?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        service = try values.decodeIfPresent(String.self, forKey: .service)
    }
}
