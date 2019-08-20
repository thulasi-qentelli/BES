//
//  SignUpViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SignUpViewModel{
    
    let besService = BESService()
    var didUserSignUp : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func signUpWith(firstName inputFirstName:String,lastName inputLastName:String,email inputEmail:String,password inputPassword:String){
        
        besService.signUpWith(firstName: inputFirstName, lastName: inputPassword, email: inputEmail, password: inputPassword)
            .done{ user in
                print(user)
                self.didUserSignUp.accept(true)
            }.catch{ error in
                print(error)
                self.didUserSignUp.accept(false)
        }
    }
    
    
}
