//
//  CommentsBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct CommentsBuilder{
    
    static func viewController() -> CommentsViewController{
        
        let commentsViewModel = CommentsViewModel()
        let commemntsRouter   = CommentsRouter()
        let viewController    = CommentsViewController(with: commentsViewModel,router: commemntsRouter)
        commemntsRouter.viewController = viewController
        return viewController
    }
}
