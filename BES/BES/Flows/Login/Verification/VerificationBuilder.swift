//
//  VerificationBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct VerificationBuilder{
    
    static func viewController() -> VerificationViewController{
        
        let verificationViewModel = VerificationViewModel()
        let verificationRouter = VerificationRouter()
        let viewController = VerificationViewController(with: verificationViewModel,verificationRouter)
        verificationRouter.viewController = viewController
        return viewController
    }
}
