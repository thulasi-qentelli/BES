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
        window?.rootViewController  =   nil
        let loginVC                 =   LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        window?.rootViewController  =   navigationController
        setNavigationBarAppearance()
    }
    
    func loadHomeView() {
        let VC1 =   MainTabbarViewController()
        let VC2 =   SideViewController()
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
