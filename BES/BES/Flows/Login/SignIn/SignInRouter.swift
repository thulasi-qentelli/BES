//
//  SignInRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import UIKit

class SignInRouter{
    
    weak var viewController : SignInViewController?
    
    func navigateToSignUp(){
        
        let signUpVC = SignUpBuilder.viewController()
        if let vc = self.viewController{
            vc.present(signUpVC, animated: true, completion: nil)
        }
    }
    
    func navigateToForgotPassword(){
        
        let forgotPasswordVC = ForgotPasswordBuilder.viewController()
        if let vc = self.viewController{
            vc.present(forgotPasswordVC, animated: true, completion: nil)
        }
    }
    
    func navigateToFeed(){
        
        let mainVC = MainBuilder.viewController()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainVC
    }
}
