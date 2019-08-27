//
//  Feed.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 23/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import ObjectMapper

class Feed: NSObject, Mappable, Codable {
    
    var id: Int?
    var content: String?
    var createdDate: String?
    var updatedDate: String?
    var userName: String?
    var userPic: String?
    var image: String?
    var email: String?
    var comments: [Comment]?
    var likes: [Like]?
    var likecount: Int?
    var likedUsers:[String]?
    
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        content <- map["content"]
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        userName <- map["userName"]
        userPic <- map["userPic"]
        image <- map["image"]
        email <- map["email"]
        comments <- map["comments"]
        likes <- map["likes"]
        likecount <- map["likecount"]
        
        if let kLikes = likes {
            self.likedUsers =  kLikes.map{$0.email ?? ""}
        }
        
    }
}

class Comment: NSObject, Mappable, Codable {
    
    var id: Int?
    var userName: String?
    var email: String?

    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userName <- map["userName"]
        email <- map["email"]
        
    }
}
class Like: NSObject, Mappable, Codable {
    
    var id: Int?
    var userName: String?
    var email: String?
    var postId: Int?
    var createdDate: String?
    var updatedDate: String?
    var likes: Int?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userName <- map["userName"]
        email <- map["email"]
        postId <- map["postId"]
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        likes <- map["likes"]
        
    }
}
