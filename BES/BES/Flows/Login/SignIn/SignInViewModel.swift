//
//  SignInViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SignInViewModel{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let besService = BESService()
    var didGetUser : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func loginWith(username inputUsername:String,password inputPassword:String){
        
        besService.loginWith(username: inputUsername, password: inputPassword)
            .done{ user in
                    print(user)
                    if user.isActive! == 1{
                        self.appDelegate.user = user
                        //Changed
                        self.didGetUser.accept(true)
//                        self.getImage(of: user.email!)
                    }else{
                        self.didGetUser.accept(false)
                    }
            }.catch{ error in
                     print(error)
                     self.didGetUser.accept(false)
            }
    }
    
    func getImage(of user:String){
        
        besService.getImage(of: user)
            .done{ user in
                self.appDelegate.userImage = user.pic
                self.didGetUser.accept(true)
            }.catch{ error in
                print(error)
                self.didGetUser.accept(false)
            
        }
    }
    
  
    
}
