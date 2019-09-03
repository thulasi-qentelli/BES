//
//  FeedViewModel.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 27/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import UIKit

class FeedViewModel {
    var feed: Feed
    var isTextExpanded: Bool = false
    var readMoreText = ""
    var isReadMoreRequired = true
    var dateForDisplay:String = ""
//    var profileImg: UIImage?
    var feedImg: UIImage?
    var feedImgHeight: CGFloat = 0
    var basicHeight: CGFloat = 138
    var expandedHeight: CGFloat = 0
    var normalHeight: CGFloat = 0
//    var profileImgDataTask:URLSessionDataTask?
    var feedImgDataTask:URLSessionDataTask?
    
    var imageUpdated:()->Void = {
        
    }
    
    init(feed:Feed) {
        self.feed = feed
        setTextForReadmore(numberOfLines: 3)
        normalHeight = readMoreText.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: UIFont.systemFont(ofSize: 14))
        expandedHeight = (feed.content! + "  Read More").height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: UIFont.systemFont(ofSize: 14))
        dateForDisplay = feed.createdDate?.date?.humanDisplayDaateFormat() ?? ""
        
//        if let kLocalImg = AppController.shared.imageCache.object(forKey: feed.userPic as NSString? ?? "" as NSString) {
//            profileImg = kLocalImg
//        }
        
        if let kLocalImg = AppController.shared.imageCache.object(forKey: feed.image as NSString? ?? "" as NSString) {
            feedImg = kLocalImg
            feedImgHeight = kLocalImg.heightForWidth(width: UIScreen.main.bounds.size.width - 60) ?? 0
        }
    }
 
    func getTextLabelContent()->String {
        return isTextExpanded ? (feed.content! + "  Read More") : readMoreText
    }
    func getDisplayTextLabelContet()->String {
        return isTextExpanded ? feed.content! : ""
    }
    func readMoreAction() {
        isTextExpanded = !isTextExpanded
    }
    
    func getExpandedHeight() -> CGFloat {
        return basicHeight + expandedHeight + feedImgHeight
    }
    func getNormaHeight() -> CGFloat {
        return basicHeight + normalHeight + feedImgHeight
    }
    
    func setTextForReadmore(numberOfLines:Int) {
        
        var height: CGFloat = 0
        var changes = 0
        var finalArr:[String] = []
        let splitArray = feed.content!.split(separator: " ")
        for i in 0..<splitArray.count {
            
            finalArr.append(String(splitArray[i]))
            
            let subStr = finalArr.joined(separator: " ")
            let newStr = String(subStr)
            let kHeight = newStr.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: UIFont.systemFont(ofSize: 14))
            
            if height == 0 {
                height = kHeight
            }
            else {
                if height != kHeight {
                    changes = changes + 1
                }
                height = kHeight
            }
            if splitArray.count == finalArr.count {
                self.isReadMoreRequired = false
                self.readMoreText = feed.content!
            }
            else if changes == numberOfLines {
                finalArr.removeLast()
                finalArr.removeLast()
                finalArr.removeLast()
                finalArr.removeLast()
                self.readMoreText =  finalArr.joined(separator: " ") + "..."
                break
            }
        }
    }
    
//    func downloadProfileImg() {
//        print("============= downloadProfileImg")
//        DispatchQueue.global(qos: .background).async {
//            if let urlString = self.feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
//                if let url  = URL(string: urlString){
//
//                    self.profileImgDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//
//                        guard let data = data, error == nil else {
//                            print("\nerror on download \(String(describing: error))")
//                            return
//                        }
//                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
//                            print("statusCode != 200; \(httpResponse.statusCode)")
//                            return
//                        }
//
//                        DispatchQueue.main.async {
//
//                            if let kImg = UIImage(data: data) {
//                                AppController.shared.imageCache.setObject(kImg, forKey: self.feed.userPic! as NSString)
//                                self.profileImg = kImg
//                                self.imageUpdated()
//                            }
//                        }
//                    })
//                    self.profileImgDataTask?.resume()
//                }
//            }
//        }
//    }
    
    func downloadFeedImg() {
        print("============= downloadFeedImg")
        DispatchQueue.global(qos: .background).async {
            if let urlString = self.feed.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                if let url  = URL(string: urlString){
                    
                    self.feedImgDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        
                        guard let data = data, error == nil else {
                            print("\nerror on download \(String(describing: error))")
                            return
                        }
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                            print("statusCode != 200; \(httpResponse.statusCode)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            if let kImg = UIImage(data: data) {
                                AppController.shared.imageCache.setObject(kImg, forKey: self.feed.image! as NSString)
                                self.feedImg = kImg
                                self.feedImgHeight = kImg.heightForWidth(width: UIScreen.main.bounds.size.width - 60) ?? 0
                                self.imageUpdated()
                            }
                        }
                    })
                    self.feedImgDataTask?.resume()
                }
            }
        }
    }
    
    
    deinit {
//        self.profileImgDataTask?.cancel()
        self.feedImgDataTask?.resume()
        print("=========== View model Deinit =========")
    }
}
