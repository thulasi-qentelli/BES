//
//  FeedbackBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct FeedbackBuilder{
    
    static func viewController() -> FeebackViewController{
        
        let viewModel = FeedbackViewModel()
        let router    = FeedbackRouter()
        let viewController = FeebackViewController(with: viewModel,router)
        router.viewController = viewController
        return viewController
    }
}
