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
    var feedImgHeight: CGFloat = 0
    var basicHeight: CGFloat = 138
    var expandedHeight: CGFloat = 0
    var normalHeight: CGFloat = 0
    var isReqInProgress:Bool = false
    
    init(feed:Feed) {
        self.feed = feed
        setTextForReadmore(numberOfLines: 3)
        normalHeight = readMoreText.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: UIFont.systemFont(ofSize: 14))
        expandedHeight = (feed.content! + "  Read More").height(withConstrainedWidth: UIScreen.main.bounds.size.width - 60, font: UIFont.systemFont(ofSize: 14))
        dateForDisplay = feed.updatedDate?.date?.humanDisplayDaateFormat() ?? ""
        
        if let imageHeight = feed.imagesize {
            let width =  imageHeight.components(separatedBy: "x").first?.floatValue ?? 1
            let height = imageHeight.components(separatedBy: "x").last?.floatValue ?? 1
            self.feedImgHeight =  ((UIScreen.main.bounds.size.width - 60)/width*height)
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
}
