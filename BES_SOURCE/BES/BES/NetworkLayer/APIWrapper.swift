
import Foundation
import UIKit
import CoreServices

extension NetworkManager {
//     static let shared = APIWrapper()
//     private init(){}

    
    private func createRequest(url:String, parm:Parameters,filePath:String, fileName: String, data: Data, mimeType:String) throws -> URLRequest {
        let parameters = parm  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(with: parameters as! [String : String], filePath: filePath, fileName: fileName, data: data, mimeType: mimeType, boundary: boundary)
        
        return request
    }
    
    private func createBody(with parameters: [String: String],filePath:String, fileName: String, data: Data, mimeType:String , boundary: String) throws -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePath)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func createRequestForMultipleFiles(url:String, parm:Parameters,filesDict:Parameters) throws -> URLRequest {
        let parameters = parm  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBodyForMultipleFiles(with: parameters as! [String : String], filesDict: filesDict as! [String : String], boundary: boundary)
        
        return request
    }
    
    
    private func createBodyForMultipleFiles(with parameters: [String: String],filesDict:[String: String] , boundary: String) throws -> Data {
        var body = Data()
        
        let fileName = "image.jpg"
        let mimeType = "image/jpg"
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        for (key, value) in filesDict {
            
            var image: UIImage? = UIImage()//_returnImage(withName: value)
            if image == nil {
                image = UIImage()//returnImage(withName: value)
            }
            let imageData = image?.jpegData(compressionQuality: 0.8) ?? Data()
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimeType)\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    private func getBasuURL() -> String{
        return "https://manage.dispatchtrack.com/api/"
    }
    
    
    private func fileUploadTask(request: URLRequest,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            if let response = response as? HTTPURLResponse {
                print("=========== Image upload response =========\n" + " StatusCode : \(response.statusCode)" + "===========================================")
                
                if response.statusCode == 200 {
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    
                    let jsonString = String(data: responseData, encoding: String.Encoding.utf8) ?? ""
                    
                    print(jsonString)
                    
                    //                    let apiResponse = CommonApiResponse(JSONString: jsonString)
                    //                    completion(apiResponse, nil)
                    
                    print("============================================")
                }
                else {
                    completion(nil, "Status code not 200")
                }
            }
            else {
                completion(nil, error?.localizedDescription)
            }
        }
        task.resume()
    }
    
    func uploadImageFile(image:UIImage,completion: @escaping (_ resopnse: Any?,_ error: String?)->()) {
        
        /*
         var parm = ParameterDetail()
         
         var imageData = Data()
         
         if image.imageCacheFileName!.contains(".mp4") {
         imageData = returnVideoData(withName: image.imageCacheFileName ?? "dsndskjdncckdckkj")
         }
         else {
         var imageFile: UIImage? = _returnImage(withName: image.imageCacheFileName ?? "skdckjcdsmnmsdkjddc")
         if imageFile == nil {
         imageFile = returnImage(withName: image.imageCacheFileName!)
         }
         imageData = imageFile?.jpegData(compressionQuality: 0.8) ?? Data()
         }
         
         if imageData.count == 0 {
         completion(nil, "Error: File not able to load properly from local storage")
         return
         }
         
         
         if let yesterDayLogin = UserDefaults.standard.getLoginModel()?.isEnableYesteradyDriverLogin(), yesterDayLogin == true {
         
         parm.internal_login = ""//Modify
         }
         
         if let dict = parm.dictionary {
         
         let url = getBasuURL() + Method.save_image.rawValue
         let filepath = "uploaded_data"
         var fileName = "image.jpg"
         var mimeType = "image/jpg"
         
         if image.imageCacheFileName!.contains(".mp4") {
         fileName = parm.timestamp!
         mimeType = "video/mp4"
         }
         
         let request: URLRequest
         
         do {
         request = try createRequest(url: url, parm: dict, filePath: filepath, fileName: fileName, data: imageData ?? Data(), mimeType: mimeType)
         
         fileUploadTask(request: request, completion: completion)
         
         } catch {
         print(error)
         completion(nil, error.localizedDescription)
         }
         
         } else { completion(nil, "Error: Parameters are not appeneded properly")}
         
         */
    }
    
}

extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}


