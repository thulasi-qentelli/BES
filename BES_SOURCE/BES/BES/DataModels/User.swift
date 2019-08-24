

import Foundation
import ObjectMapper

class User: NSObject, Mappable, Codable {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var role: String?
    var pic: String?
    var location: String?
    var createdDate: String?
    var updatedDate: String?
    var isActive: Int?
    var token: String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        email <- map["email"]
        password <- map["password"]
        role <- map["role"]
        pic <- map["pic"]
        location <- map["location"]
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        isActive <- map["isActive"]
        token <- map["token"]
     
    }
    
    func getName() -> String{
        let first = firstName ?? ""
        let last = lastName ?? ""
        return first.uppercased() + " " + last.uppercased()
    }
    func getRole() -> String{
        let first = role ?? ""
        let last = location ?? ""
        return first.capitalized + ", " + last.capitalized
    }
}


