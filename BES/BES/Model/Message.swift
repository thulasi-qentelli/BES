//
//  Message.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 02/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct Message: Codable {
    let id: Int?
    let message,fromuser,touser,createdDate,updatedDate: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        fromuser = try values.decodeIfPresent(String.self, forKey: .fromuser)
        touser = try values.decodeIfPresent(String.self, forKey: .touser)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
        updatedDate = try values.decodeIfPresent(String.self, forKey: .updatedDate)
    }
    
    init(id:Int?,message:String,fromuser:String?,touser:String?,createdDate:String?,updatedDate:String?){
        self.id = id
        self.message = message
        self.fromuser = fromuser
        self.touser = touser
        self.createdDate = createdDate
        self.updatedDate = updatedDate
    }
}


struct GroupedMessages : Codable{
    
    var date : String?
    var messges : [Message]?
    
    init(_ date:String,_ messages:[Message]){
        
        self.date = date
        self.messges = messages
    }
}


