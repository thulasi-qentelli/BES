//
//  ForgotPasswordRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class ForgotPasswordRouter{
    
    weak var viewController : ForgotPasswordViewController?
    
    func navigateToResetPassword(){
        
        let resetPasswordVC = ResetPasswordBuilder.viewController()
        if let vc = self.viewController{
            resetPasswordVC.emailId = vc.txtEmail.text
            vc.present(resetPasswordVC, animated: true, completion: nil)
        }
    }
}
