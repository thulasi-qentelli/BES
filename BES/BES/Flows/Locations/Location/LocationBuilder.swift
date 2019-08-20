//
//  LocationBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct LocationBuilder{
    
    static func viewController() -> LocationViewController{
        
        let locationViewModel = LocationViewModel()
        let locationRouter    = LocationRouter()
        let viewContorller    = LocationViewController(with: locationViewModel, locationRouter)
        locationRouter.viewController = viewContorller
        return viewContorller
    }
}
