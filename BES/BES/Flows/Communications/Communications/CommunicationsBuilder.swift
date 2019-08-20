//
//  CommunicationsBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct CommunicationsBuilder{
    
    static func viewController() -> CommunicationsViewController{
        
        let viewModel = CommunicationsViewModel()
        let router    = CommunicationsRouter()
        let viewController = CommunicationsViewController(with: viewModel,router)
        router.viewController = viewController
        return viewController
    }
}
