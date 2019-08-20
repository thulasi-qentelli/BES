//
//  SignInBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct SignInBuilder{
    
    static func viewController() -> SignInViewController{
        
        let signInViewModel = SignInViewModel()
        let signInRouter    = SignInRouter()
        let viewController  = SignInViewController(with: signInViewModel,signInRouter)
        signInRouter.viewController = viewController
        return viewController
    }
}
