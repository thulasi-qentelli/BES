//
//  CommunicationsRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class CommunicationsRouter{
    
    weak var viewController : CommunicationsViewController?
    
    func navigateToEnquiry(){
        
        let enquiryVC = EnquiryBuilder.viewController()
        if let vc = self.viewController{
            vc.present(enquiryVC, animated: true, completion: nil)
        }
    }
    
    func navigateToFeedback(){
        
        let feedbackVC = FeedbackBuilder.viewController()
        if let vc = self.viewController{
            vc.present(feedbackVC, animated: true, completion: nil)
        }
    }
    
    func navigateToProfile(){
        
        let profileVC = ProfileBuilder.viewController()
        if let vc = self.viewController{
            vc.present(profileVC, animated: true, completion: nil)
        }
    }
}
