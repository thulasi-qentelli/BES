//
//  BESService.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 30/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class BESService{
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loginWith(username inputUsername:String,password inputPassword:String) -> Promise<User> {
        return Promise<User> { seal in
           
            let url = String(format:"http://bes.qentelli.com:8085/bes/mobileLogin?email=%@&password=%@",inputUsername,inputPassword)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.post, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    let user = try? JSONDecoder().decode(User.self, from: response.data!)
                                    self.appdelegate.user = user
                                    print(user!)
                                    seal.fulfill(user!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func signUpWith(firstName inputFirstName:String,lastName inputLastName:String,email inputEmail:String,password inputPassword:String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/bes/saveUser")
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
 
            let dict = ["firstName" : inputFirstName,
                        "lastName"  : inputLastName,
                        "email"     : inputEmail,
                        "password"  : inputPassword,
                        "role"      : "user"]
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            var request = URLRequest(url: try! urlString!.asURL())
            request.httpMethod = HTTPMethod.post.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
           
            Alamofire.request(request).validate().responseData { response in
                
                switch response.result {
                case .success:
                    let success = try? JSONDecoder().decode(Bool.self, from: response.data!)
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
                
            }
        }
    }
    
    func resetPasswordFor(_ inputEmail:String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/bes/forgotPassword?email=%@&path=localhost:8085/forgot",inputEmail)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.post, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    seal.fulfill(true)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getFeeds() -> Promise<[Feed]> {
        return Promise<[Feed]> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/feed/getFeeds")
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let feeds = try? JSONDecoder().decode([Feed].self, from: response.data!)
                                    print(feeds!)
                                    seal.fulfill(feeds!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getDetails(of email:String) -> Promise<User> {
        return Promise<User> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/bes/getUserByEmail?email=%@",email)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let user = try? JSONDecoder().decode(User.self, from: response.data!)
                                    print(user!)
                                    seal.fulfill(user!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    
    func getLocations() -> Promise<[Location]> {
        return Promise<[Location]> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/location/getLocation")
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let locations = try? JSONDecoder().decode([Location].self, from: response.data!)
                                    print(locations!)
                                    seal.fulfill(locations!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getMessages() -> Promise<[Message]> {
        return Promise<[Message]> { seal in
        
            guard let user = self.appdelegate.user else { return }
            guard let email = user.email else { return }

           // var tempEmail = "sathya.kanuri@gmail.com"
            let url = String(format:"http://bes.qentelli.com:8085/message/getMessagesByEmail?email=%@",email)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let messages = try? JSONDecoder().decode([Message].self, from: response.data!)
                                    print(messages!)
                                    seal.fulfill(messages!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
   
    func sendFeeback(content inputContent:String,rating inputRating:Int,category inputCategory:String,email inputEmail:String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/feedback/saveFeedback")
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
          
            let dict = ["content"  : inputContent,
                        "rating"   : inputRating,
                        "category" : inputCategory,
                        "useremail": inputEmail] as [String : Any]
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            var request = URLRequest(url: try! urlString!.asURL())
            request.httpMethod = HTTPMethod.post.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
            
            Alamofire.request(request).validate().responseData { response in
                
                switch response.result {
                case .success:
                    let success = try? JSONDecoder().decode(Bool.self, from: response.data!)
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
                
            }
        }
    }
    
    func sendComment(text inputComment:String,postId inputPostId:Int) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/comments/saveComment")
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
          
            let user = self.appdelegate.user!
            let dict = ["comment"  : inputComment,
                        "postId" : inputPostId,
                        "email": user.email!] as [String : Any]
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            var request = URLRequest(url: try! url.asURL())
            request.httpMethod = HTTPMethod.post.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
            
            Alamofire.request(request).validate().responseData { response in
                
                switch response.result {
                case .success:
                    let success = try? JSONDecoder().decode(Bool.self, from: response.data!)
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
                
            }
        }
    }
    
    func sendEnquriy(comments inputComments:String,phonenumber inputNumber:String,location inputLocation:String,category inputCategory:String,email inputEmail:String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/Enquiry/saveEnquiry")
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
            

            let dict = ["comments":inputComments,
                        "phonenumber":inputNumber,
                        "location":inputLocation,
                        "category":inputCategory,
                        "email":inputEmail] as [String : Any]
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            var request = URLRequest(url: try! urlString!.asURL())
            request.httpMethod = HTTPMethod.post.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
            
            Alamofire.request(request).validate().responseData { response in
                
                switch response.result {
                case .success:
                    let success = try? JSONDecoder().decode(Bool.self, from: response.data!)
                    seal.fulfill(true)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
                
            }
        }
    }
   
    
    func updateuser(id inputId:Int,firstName inputFirstName:String,lastName inputLastName:String,email inputEmail:String,password inputPassword:String,location inputLocation:String) -> Promise<User> {
        return Promise<User> { seal in
            
            guard let user = appdelegate.user else {return}
            let url = String(format:"http://bes.qentelli.com:8085/bes/updateUser")
            var headers = HTTPHeaders.init()
            headers["Content-Type"]   = "application/json"
            
            let dict = ["id":inputId,
                        "firstName" : inputFirstName,
                        "lastName"  : inputLastName,
                        "email"     : inputEmail,
                        "password"  : inputPassword,
                        "role"      : user.role!,
                        "location"   : inputLocation] as [String : Any]
            var  jsonData = NSData()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) as NSData
            } catch {
                print(error.localizedDescription)
            }
            
            var request = URLRequest(url: try! url.asURL())
            request.httpMethod = HTTPMethod.put.rawValue
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData as Data
            
            Alamofire.request(request).validate().responseData { response in
                
                switch response.result {
                case .success:
                    
                    let user = try? JSONDecoder().decode(User.self, from: response.data!)
                    
                    self.appdelegate.user = user!
                    seal.fulfill(user!)
                case .failure(let error):
                    print(error)
                    seal.reject(error)
                }
                
            }
        }
    }
    
   
    func saveLike(postId inputPostId:Int) -> Promise<Bool> {
        return Promise<Bool> { seal in
            
            guard let user = appdelegate.user else {return}
            let url = String(format:"http://bes.qentelli.com:8085/likes/saveLike?email=%@&id=%d",user.email!,inputPostId)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.post, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    let user = try? JSONDecoder().decode(Feed.self, from: response.data!)
                                    seal.fulfill(true)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    
    func getCategories() -> Promise<[Category]> {
        return Promise<[Category]> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/category/getCategories")
            
            Alamofire.request(try! url.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let categories = try? JSONDecoder().decode([Category].self, from: response.data!)
                                    print(categories!)
                                    seal.fulfill(categories!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getStates() -> Promise<[State]> {
        return Promise<[State]> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/states/getStates")
            
            Alamofire.request(try! url.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let states = try? JSONDecoder().decode([State].self, from: response.data!)
                                    print(states!)
                                    seal.fulfill(states!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getImage(of user:String) -> Promise<User> {
        return Promise<User> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/bes/getUserByEmail?email=%@",user)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseString { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let user = try? JSONDecoder().decode(User.self, from: response.data!)
                                    seal.fulfill(user!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    func getImage(email inputEmail:String) -> Promise<User> {
        return Promise<User> { seal in
            
            let url = String(format:"http://bes.qentelli.com:8085/bes/getUserByEmail?email=%@",inputEmail)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            Alamofire.request(try! urlString!.asURL(), method : HTTPMethod.get, parameters : nil,
                              encoding : URLEncoding.default , headers : getHeaders()).validate().responseJSON { response in
                                
                                switch response.result {
                                case .success:
                                    print(response)
                                    let user = try? JSONDecoder().decode(User.self, from: response.data!)
                                    seal.fulfill(user!)
                                case .failure(let error):
                                    print(error)
                                    seal.reject(error)
                                }
                                
            }
        }
    }
    
    
    
    func upload(image: UIImage,identifier:String) -> Promise<Bool> {
        return Promise<Bool> { seal in
            let url = String(format:"http://bes.qentelli.com:8085/bes/uploadImage?id=\(identifier)")
            
            if let data = image.jpegData(compressionQuality: 0.50){
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(data, withName: "imageFile", fileName: "profile_image_\(identifier).jpeg", mimeType: "image/jpeg")
                    
                }, usingThreshold: UInt64.init(), to: URL(string: url)!, method: .post, headers: nil) { (result) in
                    
                    switch result{
                    case .success(let upload, _, _):
                        upload.responseString { response in
                            print(response)
                            seal.fulfill(true)
                            print("success in storing")
                        }
                    case .failure(let error):
                        print("Error in upload: \(error.localizedDescription)")
                        seal.reject(error)
                    }
                }
            }
        }
    }    
    
    private func getMultiPartHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders.init()
        headers["Content-Type"] = "multipart/form-data"
        return headers
    }
 
    private func getHeaders() -> HTTPHeaders {
       
        let headers = HTTPHeaders.init()
        return headers
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func getSize() -> Int? {
        guard let imageData = self.jpegData(compressionQuality: 0.25) else { return nil }
        let imgSizeKb = Double(imageData.count)/1024.0
        return Int(imgSizeKb/1024.0)
    }
}
