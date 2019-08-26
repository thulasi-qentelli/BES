//
//  AppController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import Foundation
import UIKit

class AppController {
    static let shared = AppController()
    private init(){}
    var user:User?
    var mainView   =   SSASideMenu()
    var window: UIWindow?
    
    func loadLoginView() {
        if let user = getUserDetails() {
            self.user = user
            let VC1 =   MainTabbarViewController()
            let VC2 =   SideViewController()
            VC2.menuTapped = { index in
                if index == 5 {
                    clearUserDetails()
                    AppController.shared.loadLoginView()
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
    
    func loadHomeView() {
        let VC1 =   MainTabbarViewController()
        let VC2 =   SideViewController()
        VC2.menuTapped = { index in
            if index == 6 {
                
            } else {
                VC1.selectedIndex = index
            }
            
        }
        mainView   =   SSASideMenu(contentViewController: VC1, leftMenuViewController: VC2)
        window?.rootViewController  =    mainView        
        setNavigationBarAppearance()
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
        clearUserDetails()
        AppController.shared.loadLoginView()
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
