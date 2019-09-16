//
//  AppController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
class AppController {
    static let shared = AppController()
    let imageCache = NSCache<NSString, UIImage>()
    private init(){}
    var user:User? {
        didSet {
            print("Changedddddd")
            (self.mainView.leftMenuViewController as? SideViewController)?.profileView.user = user
        }
    }
    var mainView   =   SSASideMenu()
    var window: UIWindow?
    
    func loadStartView() {
        if let user = getUserDetails() {
            self.user = user
            let VC1 =   MainTabbarViewController()
            let VC2 =   SideViewController()
            VC2.menuTapped = { index in
                if index == 7 {
                    self.logoutAction()
                } else {
                    VC1.selectedIndex = index
                }
            
            }
            mainView   =   SSASideMenu(contentViewController: VC1, leftMenuViewController: VC2)
            window?.rootViewController  =    mainView
            setNavigationBarAppearance()
            
        }
        else {
            window?.rootViewController  =   nil
            let loginVC                 =   LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController  =   navigationController
            setNavigationBarAppearance()
        }
    }
    
    func setNavigationBarAppearance () {
        UINavigationBar.appearance().tintColor = UIColor.white
//        UINavigationBar.appearance().barTintColor = UIColor.orange
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
    }
    
    func addNavigationButtons(navigationItem:UINavigationItem) {
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        navigationItem.titleView = imageView
        
        let menubutton = UIButton(type: .custom)
        menubutton.setImage(UIImage(named: "menu"), for: .normal)
        menubutton.addTarget(self, action: #selector(menuBtnAction), for: .touchUpInside)
        
        let barButton1 = UIBarButtonItem(customView: menubutton)
        
        let currWidth1 = barButton1.customView?.widthAnchor.constraint(equalToConstant: 28)
        currWidth1?.isActive = true
        let currHeight1 = barButton1.customView?.heightAnchor.constraint(equalToConstant: 28)
        currHeight1?.isActive = true
        navigationItem.leftBarButtonItem = barButton1
        
        
        let lopgoutbutton = UIButton(type: .custom)
        lopgoutbutton.setImage(UIImage(named: "logout_white_nav"), for: .normal)
        lopgoutbutton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: lopgoutbutton)
        
        let currWidth2 = barButton2.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth2?.isActive = true
        let currHeight2 = barButton2.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight2?.isActive = true
        navigationItem.rightBarButtonItem = barButton2
        
    }
    
    
    
    @objc func menuBtnAction() {
        self.mainView.contentViewController?.presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        
        let alert = UIAlertController(title: "BES", message: "Are You Sure Want to Logout!", preferredStyle:.alert)
        let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.forceLogoutAction()
        }
        let noButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        alert.addAction(yesButton)
        alert.addAction(noButton)
        
        self.mainView.contentViewController?.present(alert, animated: true, completion: nil)
    }
    
    func clearImageCahce() {
        imageCache.removeAllObjects()
    }
    
    
    func forceLogoutAction() {
        clearAuthToken()
        clearUserDetails()
        AppController.shared.loadStartView()
    }
    
}


func addTransitionEffect(view:UIView) {
    let animation: CATransition = CATransition()
    animation.type  =   CATransitionType.fade
    animation.duration  =   0.25
    animation.subtype   =   CATransitionSubtype.fromRight
    animation.timingFunction    =   CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    view.layer.add(animation, forKey: "fadeViewAnimation")
}

func GetAppDelegate() -> AppDelegate {
    return (UIApplication.shared.delegate as! AppDelegate)
}

func saveUserDetails(user:User) {
    let dictionary = user.dictionary
    UserDefaults.standard.set(dictionary, forKey: "LoginUserData")
    UserDefaults.standard.synchronize()
}
func getUserDetails() -> User? {
    if let dictionary = UserDefaults.standard.object(forKey: "LoginUserData") {
        let user = User(JSON: dictionary as! [String: Any])
        return user
    }
    return nil
}
func clearUserDetails() {
    UserDefaults.standard.removeObject(forKey: "LoginUserData")
    UserDefaults.standard.synchronize()
}

func saveAuthToken(token:String) {
    UserDefaults.standard.set(token, forKey: "AuthTokenForUser")
    UserDefaults.standard.synchronize()
}
func getAuthToken() -> String? {
    if let value = UserDefaults.standard.object(forKey: "AuthTokenForUser") {
        return value as? String
    }
    return nil
}
func clearAuthToken() {
    UserDefaults.standard.removeObject(forKey: "AuthTokenForUser")
    UserDefaults.standard.synchronize()
}

func saveFeedsLocally(feeds:String) {
    UserDefaults.standard.set(feeds, forKey: "FeedsBES")
    UserDefaults.standard.synchronize()
}

func getLocalFeeds()-> [Feed]? {
    
    if let string = UserDefaults.standard.object(forKey: "FeedsBES") {
        if let feeds = Mapper<Feed>().mapArray(JSONString: string as! String) {
            return feeds
        }
    }
    return nil
}

func saveMessagesLocally(messages:String) {
    UserDefaults.standard.set(messages, forKey: "MessagesBES")
    UserDefaults.standard.synchronize()
}

func getLocalMessages()-> [Message]? {
    
    if let string = UserDefaults.standard.object(forKey: "MessagesBES") {
        if let feeds = Mapper<Message>().mapArray(JSONString: string as! String) {
            return feeds
        }
    }
    return nil
}

func saveLocaitonsLocally(locaitons:String) {
    UserDefaults.standard.set(locaitons, forKey: "LocationsBES")
    UserDefaults.standard.synchronize()
}

func getLocalLocaitons()-> [Location]? {
    
    if let string = UserDefaults.standard.object(forKey: "LocationsBES") {
        if let feeds = Mapper<Location>().mapArray(JSONString: string as! String) {
            return feeds
        }
    }
    return nil
}


