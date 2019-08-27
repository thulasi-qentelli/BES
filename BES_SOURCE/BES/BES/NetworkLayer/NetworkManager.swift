
import Foundation
import Alamofire
import ObjectMapper

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()
public typealias HTTPHeaders = [String:String]
public typealias Parameters = [String:Any]
public typealias ServiceResponse = (NSDictionary?, NSError?) -> Void

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case serverError = "Internal Server Error"
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

public enum Method: String {
    case login = "bes/mobileLogin"
    case forgotPassword = "bes/forgotPassword"
    case saveUser = "bes/saveUser"
    case updateUser = "bes/updateUser"
    case getMessagesByEmail = "message/getMessagesByEmail"
    case getAllFeeds = "feed/getFeeds"
    case getAllLocations = "location/getLocation"
    case uploadImage = "bes/uploadImage"
    case getUser = "bes/getUserById"
    case getStates = "states/getStates"
    case getCategories = "category/getCategories"
    case saveInquiry = "Enquiry/saveEnquiry"
    case saveFeedback = "feedback/saveFeedback"
}

enum NetworkEnvironment: String {
    case sandboxURL = "http://bes.qentelli.com:8085/"
    case productionURL = "http://besconnect.qentelli.com:8085/"
}

enum Result<String>{
    case success
    case failure(String)
}


struct NetworkManager {
    let environment : NetworkEnvironment = .sandboxURL
    
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> String{
        switch response.statusCode {
        case 200...299: return "success"
        case 400...499: return NetworkResponse.authenticationError.rawValue
        case 500: return NetworkResponse.serverError.rawValue
        case 501...599: return NetworkResponse.badRequest.rawValue
        case 600: return NetworkResponse.outdated.rawValue
        default: return NetworkResponse.failed.rawValue
        }
    }

    
    func get(method: Method, parameters: Parameters ,completion: @escaping (_ resopnse: Any?,_ error: String?)->()){
        
        if !Common.hasConnectivity() {
            completion(nil,networkUnavailable)
            return
        }
        var url =  String(format:"\(environment.rawValue)\(method.rawValue)?\(parameters.urlEncodeString)")
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        var request = URLRequest(url: try! urlString!.asURL())
        request.httpMethod = HTTPMethod.get.rawValue
        
        if let auth = getAuthToken() {
            request.addValue(auth, forHTTPHeaderField: "Authorization")
        }
        
        Alamofire.request(request).validate().responseJSON { response in
                            
                            switch response.result {
                            case .success:
                                guard let responseData = response.data else {
                                    completion(nil, NetworkResponse.noData.rawValue)
                                    return
                                }
                                
                                let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                                print(jsonString)
                                
                                switch method {
                                case .getMessagesByEmail:
                                    if let messages = Mapper<Message>().mapArray(JSONString: jsonString) {
                                        completion(messages,nil)
                                    }
                                    else {
                                        completion(nil, jsonString)
                                    }
                                case .getAllFeeds:
                                    if let messages = Mapper<Feed>().mapArray(JSONString: jsonString) {
                                        completion(messages,nil)
                                    }
                                    else {
                                        completion(nil, jsonString)
                                    }
                                case .getAllLocations:
                                    if let messages = Mapper<Location>().mapArray(JSONString: jsonString) {
                                        completion(messages,nil)
                                    }
                                    else {
                                        completion(nil, jsonString)
                                    }
                                case .getUser:
                                    if let user = User(JSONString: jsonString), let id = user.id, id>0 {
                                        completion(user,nil)
                                    }
                                    else {
                                        completion(nil,jsonString)
                                    }
                                case .getStates:
                                    if let states = Mapper<State>().mapArray(JSONString: jsonString) {
                                        completion(states,nil)
                                    }
                                    else {
                                        completion(nil, jsonString)
                                    }
                                case .getCategories:
                                    if let states = Mapper<Category>().mapArray(JSONString: jsonString) {
                                        completion(states,nil)
                                    }
                                    else {
                                        completion(nil, jsonString)
                                    }
                                    
                                default:
                                    print("========================")
                                    
                                }
                            case .failure(let error):
                                
                                print(error)
                                if let resp = response.response {
                                    let errorMessage = self.handleNetworkResponse(resp)
                                    completion(nil, errorMessage)
                                }
                                else {
                                    completion(nil, "We are building... Please wait for some time.")
                                }
                                
                            }
                            
        }
    }
    
    func post(method: Method, parameters: Parameters,isURLEncode:Bool = true ,completion: @escaping (_ resopnse: Any?,_ error: String?)->()){
        if !Common.hasConnectivity() {
            completion(nil,networkUnavailable)
            return
        }
        var url = String(format:"\(environment.rawValue)\(method.rawValue)")
        
        if isURLEncode {
            url = String(format:"\(environment.rawValue)\(method.rawValue)?\(parameters.urlEncodeString)")
        }
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        var headers = HTTPHeaders.init()
//        headers["Content-Type"]   = "application/json"
//
//        var request = URLRequest(url: try! urlString!.asURL())
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.allHTTPHeaderFields = headers
        
        
        var request = URLRequest(url: try! urlString!.asURL())
        request.httpMethod = HTTPMethod.post.rawValue
        
        if let auth = getAuthToken(), method != .login, method != .saveUser, method != .forgotPassword  {
            request.addValue(auth, forHTTPHeaderField: "Authorization")
        }
        
        if !isURLEncode {
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
            
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
        }
        
        Alamofire.request(request).validate().responseData { response in
            
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    completion(nil, NetworkResponse.noData.rawValue)
                    return
                }
                
                let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                print(jsonString)
                
                switch method {
                case .login:
                    if let user = User(JSONString: jsonString),user.id ?? 0 > 0  {
                        completion(user,nil)
                    }
                    else {
                        completion(nil,jsonString)
                    }
                case.forgotPassword:
                    completion(jsonString,nil)
                case .saveUser:
                    if let user = User(JSONString: jsonString),user.id ?? 0 > 0 {
                       completion(user,nil)
                    }
                    else {
                        completion(nil,"User already exists.")
                    }
                case .saveInquiry:
                    print(response.response?.statusCode)
                    if response.response?.statusCode == 200 {
                        completion("success", nil)
                    }
                    else {
                        completion(nil, "Feedback not submitted due to unknown error. Pleasetry later")
                    }
                case .saveFeedback:
                    print(response.response?.statusCode)
                    if response.response?.statusCode == 200 {
                        completion("success", nil)
                    }
                    else {
                        completion(nil, "Feedback not submitted due to unknown error. Pleasetry later")
                    }
                    
                default:
                    print("========================")
                    
                }
            case .failure(let error):
                print(error)
                switch method {
                case .login:
                    if response.response?.statusCode == 500 {
                        completion(nil, "User doesn't exists.")
                    }
                    else if response.response?.statusCode == 400 {
                        completion(nil, "Enter valid Email or Password.")
                    }
                    else {
                        let errorMessage = self.handleNetworkResponse(response.response!)
                        completion(nil, errorMessage)
                    }
                case .forgotPassword:
                    print(response.response?.statusCode)
                    if response.response?.statusCode == 500 {
                        completion(nil, "Enter valid Email.")
                    }
//                    else if response.response?.statusCode == 400 {
//                        completion(nil, "User does not exist with this email.")
//                    }
                    else {
                        let errorMessage = self.handleNetworkResponse(response.response!)
                        completion(nil, errorMessage)
                    }
                    
                default:
                    print("========================")
                    let errorMessage = self.handleNetworkResponse(response.response!)
                    completion(nil, errorMessage)
                    
                }
            }
            
        }
        
    }
   
    
    func put(method: Method, parameters: Parameters,isURLEncode:Bool = true ,completion: @escaping (_ resopnse: Any?,_ error: String?)->()){
        if !Common.hasConnectivity() {
            completion(nil,networkUnavailable)
            return
        }
        var url = String(format:"\(environment.rawValue)\(method.rawValue)")
        
        if isURLEncode {
            url = String(format:"\(environment.rawValue)\(method.rawValue)?\(parameters.urlEncodeString)")
        }
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        
        var request = URLRequest(url: try! urlString!.asURL())
        request.httpMethod = HTTPMethod.put.rawValue
        
        if let auth = getAuthToken()  {
            request.addValue(auth, forHTTPHeaderField: "Authorization")
        }
        
        if !isURLEncode {
            
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
            
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
        }
        
        Alamofire.request(request).validate().responseData { response in
            
            switch response.result {
            case .success:
                guard let responseData = response.data else {
                    completion(nil, NetworkResponse.noData.rawValue)
                    return
                }
                
                let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                print(jsonString)
                
                switch method {
                case .updateUser:
                    if let user = User(JSONString: jsonString),user.id ?? 0 > 0  {
                        completion(user,nil)
                    }
                    else {
                        completion(nil,jsonString)
                    }
        
                default:
                    print("========================")
                    
                }
            case .failure(let error):
                print(error)
                switch method {
                default:
                    print("========================")
                    let errorMessage = self.handleNetworkResponse(response.response!)
                    completion(nil, errorMessage)
                    
                }
            }
            
        }
        
    }
    func uploadImage(method: Method, parameters: Parameters,image: UIImage,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        if !Common.hasConnectivity() {
            completion(nil,networkUnavailable)
            return
        }
        let url = String(format:"\(environment.rawValue)\(method.rawValue)?\(parameters.urlEncodeString)")
        
            if let data = image.jpegData(compressionQuality: 0.50){
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(data, withName: "imageFile", fileName: "profile_image_\(parameters["id"]!).jpeg", mimeType: "image/jpeg")
                    
                }, usingThreshold: UInt64.init(), to: URL(string: url)!, method: .post, headers: nil) { (result) in
                    
                    switch result{
                    case .success(let upload, _, _):
                        upload.responseString { response in
                            guard let responseData = response.data else {
                                completion(nil, NetworkResponse.noData.rawValue)
                                return
                            }
                            
                            let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                            print(jsonString)
                            
                            if let user = User(JSONString: jsonString), let id = user.id, id > 0 {
                                completion(user,nil)
                            }
                            else {
                                completion(nil,"Error while uploading profile image. Please try later.")
                            }
                        }
                       
                    case .failure(let error):
                        completion(nil, error.localizedDescription)
                    }
                }
            }
    }
}



