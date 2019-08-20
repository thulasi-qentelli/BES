//
//  SignUpBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct SignUpBuilder{
    
    static func viewController() -> SignUpViewController{
        
        let signUpViewModel = SignUpViewModel()
        let signUpRouter    = SignUpRouter()
        let viewController  = SignUpViewController(with: signUpViewModel,signUpRouter)
        signUpRouter.viewController = viewController
        return viewController
    }
}
