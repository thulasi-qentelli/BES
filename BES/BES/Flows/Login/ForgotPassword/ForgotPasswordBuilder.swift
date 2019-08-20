//
//  ForgotPasswordBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct ForgotPasswordBuilder{
    
    static func viewController() -> ForgotPasswordViewController{
        
        let forgotPasswordViewModel = ForgotPasswordViewModel()
        let forgotPasswordRouter    = ForgotPasswordRouter()
        let viewController = ForgotPasswordViewController(with: forgotPasswordViewModel,forgotPasswordRouter)
        forgotPasswordRouter.viewController = viewController
        return viewController
    }
}
