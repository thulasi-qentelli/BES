//
//  Feed.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct Feed: Codable {
    var id,likecount: Int?
    var content, image, createdDate, updatedDate,userPic: String?
    var email,userName: String?
    var comments : [Comment]?
    var likes : [Like]?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        content = try values.decodeIfPresent(String.self, forKey: .content)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        likecount = try values.decodeIfPresent(Int.self, forKey: .likecount)
        comments = try values.decodeIfPresent([Comment].self, forKey: .comments)
        likes = try values.decodeIfPresent([Like].self, forKey: .likes)
        userPic = try values.decodeIfPresent(String.self, forKey: .userPic)
    }
}
