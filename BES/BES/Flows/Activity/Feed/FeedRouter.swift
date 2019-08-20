//
//  FeedRouter.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation

class FeedRouter{
    
    weak var viewController : FeedViewController?
    
    func navigateToProfile(){
        
        let profileVC = ProfileBuilder.viewController()
        if let vc = self.viewController{
            vc.present(profileVC, animated: true, completion: nil)
        }
    }
    
    func navigateToComments(with comments:[Comment],postId:Int){
        
        let commentsVC = CommentsBuilder.viewController()
        if let vc = self.viewController{
            commentsVC.postID = postId
            commentsVC.comments = comments
            vc.present(commentsVC, animated: true, completion: nil)
        }
    }
    
}
