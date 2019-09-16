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
    var likeObj: Like?
    var likecount: Int?
    var likedUsers:[String]?
    var createdDateObj: Date?
    var updatedDateObj: Date?
    var imagesize: String?
    
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
        likeObj <- map["likeObj"]
        imagesize <- map["imagesize"]
        
        if let kLikes = likes {
            self.likedUsers =  kLikes.map{$0.email ?? ""}
            let userEmail = AppController.shared.user?.email
            let filteredLikes = kLikes.filter{ $0.email?.lowercased().contains(userEmail!.lowercased()) ?? false }
            if filteredLikes.count > 0 {
                self.likeObj = filteredLikes.last
            }
        }
        
        if let created = createdDate {
            self.createdDateObj = created.date
        }
        if let updated = updatedDate {
            self.updatedDateObj = updated.date
        }
        
    }
    
    func likeAction(completion:@escaping (Bool, String?)->Void) {
        if let user = AppController.shared.user {
            if let likedObj = self.likeObj {
                //Put like
                if likedObj.likes! == 0 {
                    self.likeObj?.likes = 1
                    completion(true,nil)
                    NetworkManager().put(method: .updateLike, parameters: ["id":"\(likedObj.id!)","email":"\(user.email!)","likes" :  "1"],isURLEncode: false) { (result, error) in
                        if error != nil {
                            self.likeObj?.likes = 0
                            completion(false, error)
                        }
                        else {
                            completion(true,nil)
                        }
                    }
                }
            }
            else {
                //Save like
                let like = Like()
                like.id = 0
                like.email = user.email
                like.likes = 1
                self.likeObj = like
                self.likes?.append(like)
                completion(true,nil)
                
                NetworkManager().post(method: .saveLike, parameters: ["id":"\(self.id!)","email":"\(user.email!)"]) { (result, error) in
                    if error != nil {
                        self.likeObj = nil
                        if let filteredLikes = self.likes?.filter({$0.id != 0}),filteredLikes.count > 0 {
                            self.likes = filteredLikes
                        }
                        else {
                            self.likes = []
                        }
                        completion(false, error)
                    }
                    else {
                        
                        if let kLikes = (result as? Feed)?.likes {
                            self.likes = kLikes
                            self.likedUsers =  kLikes.map{$0.email ?? ""}
                            let userEmail = AppController.shared.user?.email
                            let filteredLikes = kLikes.filter{ $0.email?.lowercased().contains(userEmail!.lowercased()) ?? false }
                            if filteredLikes.count > 0 {
                                self.likeObj = filteredLikes.last
                                completion(true,nil)
                            }
                            else {
                                completion(false,"Unknown error")
                            }
                        }
                        else {
                            self.likeObj = nil
                            if let filteredLikes = self.likes?.filter({$0.id != 0}),filteredLikes.count > 0 {
                                self.likes = filteredLikes
                            }
                            else {
                                self.likes = []
                            }
                            completion(false, "Unknown error")
                        }
                    }
                }
            }
        }
    }
    
    func getLikesCount()-> Int {
        if let kLikes = likes {
            let filteredLikes = kLikes.filter{ $0.likes! == 1}
            return filteredLikes.count
        }
        return 0
    }
}

class Comment: NSObject, Mappable, Codable {
    
    var id: Int?
    var userName: String?
    var email: String?
    var comment: String?
    var createdDate: String?
    var updatedDate: String?
    var userPic: String?
    var postId: Int?
    var dateShortForm:String?
    var timeShortForm:String?
    var createdDateObj: Date?
    var updatedDateObj: Date?
    var isNameRequired:Bool = false
    
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
        comment <- map["comment"]
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        userPic <- map["userPic"]
        postId <- map["postId"]
        
        if let created = createdDate {
            let splitArr = created.split(separator: " ")
            dateShortForm =  String(splitArr.first ?? "")
            timeShortForm = String(splitArr.last ?? "")
        }
        
        if let created = createdDate {
            self.createdDateObj = created.date
        }
        if let updated = updatedDate {
            self.updatedDateObj = updated.date
        }
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
