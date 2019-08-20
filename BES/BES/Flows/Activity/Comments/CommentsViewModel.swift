//
//  CommentsViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class CommentsViewModel{

    let besService = BESService()
    var didSendComment : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func sendComment(with text:String,for postId:Int){
        
        besService.sendComment(text: text, postId: postId)
            .done{ feeds in
                self.didSendComment.accept(true)
            }.catch{ error in
                print(error)
                self.didSendComment.accept(false)
        }
    }
}
