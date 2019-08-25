import Foundation
import ObjectMapper

class Message: NSObject, Mappable, Codable {
    
    var id: Int?
    var message: String?
    var fromuser: String?
    var touser: String?
    var createdDate: String?
    var updatedDate: String?
    var userName: String?
    var userPic: String?
    var dateShortForm:String?
    var timeShortForm:String?
    
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        message <- map["message"]
        fromuser <- map["fromuser"]
        touser <- map["touser"]
        createdDate <- map["createdDate"]
        updatedDate <- map["updatedDate"]
        userName <- map["userName"]
        userPic <- map["userPic"]
        
        if let created = createdDate {
            let splitArr = created.split(separator: " ")
            dateShortForm =  String(splitArr.first ?? "")
            timeShortForm = String(splitArr.last ?? "")
        }
        
    }
}


