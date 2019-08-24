
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
    case getMessagesByEmail = "message/getMessagesByEmail"
    case getAllFeeds = "feed/getFeeds"
    case getAllLocations = "location/getLocation"
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
//        var headers = HTTPHeaders.init()
//        headers["Content-Type"]   = "application/json"
    
        
        var request = URLRequest(url: try! urlString!.asURL())
//        request.allHTTPHeaderFields = headers
        request.httpMethod = HTTPMethod.get.rawValue
        
        if let auth = AppController.shared.user?.token {
//            headers["Authorization"] = auth
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
                                    
                                default:
                                    print("========================")
                                    
                                }
                            case .failure(let error):
                                
                                print(error)
                                let errorMessage = self.handleNetworkResponse(response.response!)
                                completion(nil, errorMessage)
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
        var headers = HTTPHeaders.init()
        headers["Content-Type"]   = "application/json"
        
        var request = URLRequest(url: try! urlString!.asURL())
        request.httpMethod = HTTPMethod.post.rawValue
        request.allHTTPHeaderFields = headers
        if isURLEncode {
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
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
                    if let user = User(JSONString: jsonString) {
                        completion(user,nil)
                    }
                    else {
                        completion(nil,jsonString)
                    }
                    
                case .saveUser:
                    print("")
                default:
                    print("========================")
                    
                }
            case .failure(let error):
                print(error)
                switch method {
                case .login:
                    print("")
                    if response.response?.statusCode == 400 {
                        completion(nil, "Entered email and password are wrong.")
                    }
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
}



