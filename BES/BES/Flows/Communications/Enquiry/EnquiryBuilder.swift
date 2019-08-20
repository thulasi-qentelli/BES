//
//  EnquiryBuilder.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

struct EnquiryBuilder{
    
    static func viewController() -> EnquiryViewController{
        
        let viewModel = EnquriyViewModel()
        let router    = EnquiryRouter()
        let viewController = EnquiryViewController(with: viewModel, router)
        router.viewController = viewController
        return viewController
    }
}
