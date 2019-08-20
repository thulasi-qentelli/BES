//
//  ResetPasswordBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct ResetPasswordBuilder{
    
    static func viewController() -> ResetPasswordViewController{
        
        let resetPasswordViewModel = ResetPasswordViewModel()
        let resetPasswordRouter    = ResetPasswordRouter()
        let viewController = ResetPasswordViewController(with: resetPasswordViewModel,resetPasswordRouter)
        resetPasswordRouter.viewController = viewController
        return viewController
    }
}
