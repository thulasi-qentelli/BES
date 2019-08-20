//
//  ProfileBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct ProfileBuilder{
    
    static func viewController() -> ProfileViewController{
        
        let viewModel = ProfileViewModel()
        let router   = ProfileRouter()
        let viewController = ProfileViewController(with: viewModel,router)
        router.viewController = viewController
        return viewController
    }
}
