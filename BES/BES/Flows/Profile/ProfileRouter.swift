//
//  ProfileRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class ProfileRouter{
    
    weak var viewController : ProfileViewController?
    
    func close(){
        
        if let vc = self.viewController{
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
