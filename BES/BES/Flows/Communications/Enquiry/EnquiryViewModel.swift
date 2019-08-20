//
//  EnquiryViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EnquriyViewModel{
    
    let besService = BESService()
    var didSendEnquiry : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var didGetStates : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var didGetCategories : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var categories = [String]()
    var locations = [String]()
    
    func getLocations(){
        
        besService.getStates()
            .done{ states in
                
                for each in states{
                    self.locations.append(each.statename!)
                }
                self.didGetStates.accept(true)
            }.catch{ error in
                print(error)
                self.didGetStates.accept(false)
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
    
    func sendEnquiry(comments inputComments:String,phoneNumber inputNumber:String,location inputLocation:String,category inputCategory:String,email inputEmail:String){
        
        besService.sendEnquriy(comments: inputComments, phonenumber: inputNumber, location: inputLocation, category: inputCategory, email: inputEmail)
            .done{ success in
                self.didSendEnquiry.accept(true)
            }.catch{ error in
                print(error)
                self.didSendEnquiry.accept(false)
        }
    }
}
