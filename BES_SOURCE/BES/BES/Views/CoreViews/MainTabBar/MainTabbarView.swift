//
//  MainTabbarView.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import UIKit

class MainTabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor   =   UIColor.white
        
        // Do any additional setup after loading the view.
        
        // Create Tab one
        let home     =   FeedViewController()
        if let feeds = getLocalFeeds() {
            home.feeds = feeds.sorted(by: { $0.createdDateObj!.compare($1.createdDateObj!) == .orderedDescending })
        }
        let navOne = UINavigationController(rootViewController: home)
        let homeBarItem = UITabBarItem(title: "Home".uppercased(), image: UIImage(named: "home_blue"), selectedImage: UIImage(named: "home_blue"))
        navOne.tabBarItem = homeBarItem
        
        // Create Tab two
        let locationsVC = LocationsViewController()
        if let locations = getLocalLocaitons() {
            locationsVC.locations = locations
            locationsVC.locations.sort(by: { (loc1, loc2) -> Bool in
                loc1.getTitle() < loc2.getTitle()
            })
            locationsVC.filteredLocations = locationsVC.locations
        }
        let navTwo = UINavigationController(rootViewController: locationsVC)
        let locationsBarItem = UITabBarItem(title: "Locations".uppercased(), image: UIImage(named: "location"), selectedImage: UIImage(named: "location_blue"))
        navTwo.tabBarItem = locationsBarItem
        
        let messages = MessagesViewController()
        if let kmess = getLocalMessages() {
            let datesArray = kmess.compactMap { $0.dateShortForm }
            var dic = [String:[Message]]()
            datesArray.forEach {
                let dateKey = $0
                let filterArray = kmess.filter { $0.dateShortForm == dateKey }
                dic[$0] = filterArray//.sorted(){$0.timeShortForm < $1.timeShortForm}
            }
            let keysArr = dic.keys
            messages.keys =  keysArr.sorted().reversed()
            messages.messages = dic

        }
        let navThree = UINavigationController(rootViewController: messages)
        let messagesBarItem = UITabBarItem(title: "Messages".uppercased(), image: UIImage(named: "forum"), selectedImage: UIImage(named: "forum_blue"))
        navThree.tabBarItem = messagesBarItem
        
        let feedback = FeedbackViewController()
        let navFour = UINavigationController(rootViewController: feedback)
        let feedbackBarItem = UITabBarItem(title: "Feedback".uppercased(), image: UIImage(named: "chat"), selectedImage: UIImage(named: "chat_blue"))
        navFour.tabBarItem = feedbackBarItem
        
        let inquiry = InquiryViewController()
        let navFive = UINavigationController(rootViewController: inquiry)
        let inquiryBarItem = UITabBarItem(title: "Inquiry".uppercased(), image: UIImage(named: "live_help"), selectedImage: UIImage(named: "live_help_blue"))
        navFive.tabBarItem = inquiryBarItem
        
        let invoiceVC = InvoiceViewController()
        let navSix = UINavigationController(rootViewController: invoiceVC)
        let invoiceBarItem = UITabBarItem(title: "Invoices".uppercased(), image: UIImage(named: "receipt_grey"), selectedImage: UIImage(named: "receipt"))
        navSix.tabBarItem = invoiceBarItem
        
        
        let documentationVC = DocumentsViewController()
        let navSeven = UINavigationController(rootViewController: documentationVC)
        let documentationBarItem = UITabBarItem(title: "Documents".uppercased(), image: UIImage(named: "documents_grey"), selectedImage: UIImage(named: "documents"))
        navSeven.tabBarItem = documentationBarItem
        
        
        self.viewControllers = [navOne, navTwo, navThree, navFour, navFive, navSix, navSeven]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
