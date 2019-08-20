//
//  MainViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    fileprivate var viewModel : MainViewModel!
    fileprivate var router    : MainRouter!

    init(with viewModel:MainViewModel,_ router:MainRouter){
        
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: "MainViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let feedVC = FeedBuilder.viewController()
        feedVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "feed_active"), selectedImage: UIImage(named: "feed_3"))

        
        let locationVC = LocationBuilder.viewController()
        locationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "location_active"), selectedImage: UIImage(named: "location_inactive"))
       
    
        let messagesVC = MessagesBuilder.viewController()
        messagesVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "message_active"), selectedImage: UIImage(named: "message_inactive"))
        
        let communicationsVC = CommunicationsBuilder.viewController()
        communicationsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "communication_inactive"), selectedImage: UIImage(named: "communication_active"))
        
        
        let invoiceVC = InvoiceViewController()
        invoiceVC.title = "Invoice"
        invoiceVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Invoice_grey"), selectedImage: UIImage(named: "Invoice"))
        
        let documentationVC = InvoiceViewController()
        documentationVC.title = "Documentation"
        documentationVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "documentation_grey"), selectedImage: UIImage(named: "documentation"))
        
        
        let tabBarList = [feedVC,locationVC,messagesVC,communicationsVC, invoiceVC, documentationVC]
        
        self.tabBar.backgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        viewControllers = tabBarList
    }

   


}
