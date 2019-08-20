//
//  FeedBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import UIKit


struct FeedBuilder{
    
    static func viewController() -> UINavigationController{
        
        let feedViewModel = FeedViewModel()
        let feedRouter    = FeedRouter()
        let viewController = FeedViewController(with: feedViewModel,feedRouter)
        let navigationController = UINavigationController(rootViewController: viewController)
        feedRouter.viewController = viewController
        return navigationController
        
    }
}
