//
//  SignUpRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class SignUpRouter{
    
    weak var viewController : SignUpViewController?
    
    func navigateToSignIn(){
        
        if let vc = self.viewController{
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    func navigateToVerification(){
        
        let verificationVC = VerificationBuilder.viewController()
        if let vc = self.viewController{
            vc.present(verificationVC, animated: true, completion: nil)
        }
    }
    
    
}
