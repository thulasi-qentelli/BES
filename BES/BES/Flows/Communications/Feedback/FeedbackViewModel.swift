//
//  FeedbackViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FeedbackViewModel{
    
    let besService = BESService()
    var didSendFeedback : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var didGetCategories : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var categories = [String]()
    
    func sendFeedback(content inputContent:String,rating inputRating:Int,category inputCategory:String,email inputEmail:String){
        
        besService.sendFeeback(content: inputContent,rating: inputRating,category: inputCategory,email: inputEmail)
            .done{ success in
                self.didSendFeedback.accept(true)
            }.catch{ error in
                print(error)
                self.didSendFeedback.accept(false)
        }
    }
    
    func getCategories(){
        
        besService.getCategories()
            .done{ categories in
                for each in categories{
                    self.categories.append(each.service!)
                }
                self.didGetCategories.accept(true)
            }.catch{ error in
                print(error)
                self.didGetCategories.accept(true)
        }
    }
}
