//
//  DateExtension.swift
//  NLTest
//
//  Created by Tulasi on 01/08/19.
//  Copyright © 2019 Assignment. All rights reserved.
//

import Foundation

extension Date {
    
    var messageHeaderDate: String {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEEE, MMMM"
            let firstString = dateFormatterPrint.string(from: self)
            dateFormatterPrint.dateFormat = "dd"
            let kTest =  dateFormatterPrint.string(from: self)
            let kInt = Int(kTest)
            let secondString = formatter.string(from: kInt! as NSNumber)
            
            dateFormatterPrint.dateFormat = "yyyy"
            let thirdString = dateFormatterPrint.string(from: self)
            
            return firstString + " \(secondString!) \(thirdString)"
        }
    }
    
    var displayDate: String {
        get {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd-MM-yyyy"
            return dateFormatterPrint.string(from: self)
        }
    }
    
    var displayTime: String {
        get {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "hh:mm a"
            return dateFormatterPrint.string(from: self)
        }
    }
    
    func humanDisplayDaateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        let time = "\(dateFormatter.string(from: self)) at \(timeFormatter.string(from: self))"
        return time    // prints "Today, 5:10 PM"
    }
    

    
}

extension Int {
    var date: Date {
        get {
            return Date(timeIntervalSince1970: TimeInterval(self))
        }
    }
}
