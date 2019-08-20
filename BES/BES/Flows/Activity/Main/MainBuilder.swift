//
//  MainBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct MainBuilder{
    
    static func viewController() -> MainViewController{
        
        let viewModel = MainViewModel()
        let router    = MainRouter()
        let viewController = MainViewController(with: viewModel,router)
        router.viewController = viewController
        return viewController
    }
}
