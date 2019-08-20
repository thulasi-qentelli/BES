//
//  Comment.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 03/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation


struct Like: Codable {
    let id: Int?
    let userName,email,createdDate,updatedDate: String?
    let likes,postId:Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        likes = try values.decode(Int.self, forKey: .likes)
        postId = try values.decode(Int.self, forKey: .postId)
    }
    
    init(id: Int?,userName:String,email:String?,createdDate:String?,updatedDate: String?,
         like:Int?,postId:Int?){
        self.id = id
        self.userName = userName
        self.email = email
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.likes = like
        self.postId = postId
    }
    
    
}



struct Comment: Codable {
    let id: Int?
    let userName,comment,email,createdDate,updatedDate: String?
    let postId:Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        userName = try values.decodeIfPresent(String.self, forKey: .userName)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
        postId = try values.decode(Int.self, forKey: .postId)
    }
    
    init(id: Int?,userName:String,email:String?,comment:String,createdDate:String?,updatedDate: String?,
         like:Int?,postId:Int?){
        self.id = id
        self.userName = userName
        self.email = email
        self.comment = comment
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.postId = postId
    }
    
   
}
