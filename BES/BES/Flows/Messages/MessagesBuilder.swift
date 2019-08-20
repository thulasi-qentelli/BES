//
//  MessagesBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct MessagesBuilder{
    
    static func viewController() -> MessagesViewController{
        
        let messagesViewModel = MessagesViewModel()
        let messagesRouter    = MessagesRouter()
        let viewController    = MessagesViewController(with: messagesViewModel,messagesRouter)
        messagesRouter.viewController = viewController
        return viewController
    }
}
