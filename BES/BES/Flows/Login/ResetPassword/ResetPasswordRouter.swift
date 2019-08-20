//
//  ResetPasswordRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class ResetPasswordRouter{
    
    weak var viewController : ResetPasswordViewController?
    
    func navigateToSignIn(){
        
        if let vc = self.viewController{
            vc.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
