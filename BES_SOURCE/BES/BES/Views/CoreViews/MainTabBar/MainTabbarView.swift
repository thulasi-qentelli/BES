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
        let navOne = UINavigationController(rootViewController: home)
        let homeBarItem = UITabBarItem(title: "Home".uppercased(), image: UIImage(named: "home_blue"), selectedImage: UIImage(named: "home_blue"))
        navOne.tabBarItem = homeBarItem
        
        // Create Tab two
        let locations = LocationsViewController()
        let navTwo = UINavigationController(rootViewController: locations)
        let locationsBarItem = UITabBarItem(title: "Locations".uppercased(), image: UIImage(named: "location"), selectedImage: UIImage(named: "location_blue"))
        navTwo.tabBarItem = locationsBarItem
        
        let messages = MessagesViewController()
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
        
        
        self.viewControllers = [navOne, navTwo, navThree, navFour, navFive]
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
