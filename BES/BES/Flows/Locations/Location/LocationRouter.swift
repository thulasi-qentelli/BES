//
//  LocationRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class LocationRouter{
    
    weak var viewController : LocationViewController?
    
    func navigateToProfile(){
        
        let profileVC = ProfileBuilder.viewController()
        if let vc = self.viewController{
            vc.present(profileVC, animated: true, completion: nil)
        }
    }
    
    
}
