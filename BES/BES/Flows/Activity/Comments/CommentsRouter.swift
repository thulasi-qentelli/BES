//
//  CommentsRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class CommentsRouter{
    
    weak var viewController : CommentsViewController?
    
    func close(){
        
        if let vc = self.viewController{
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    func navigateToProfile(){
        
        let profileVC = ProfileBuilder.viewController()
        if let vc = self.viewController{
            vc.present(profileVC, animated: true, completion: nil)
        }
    }
}

