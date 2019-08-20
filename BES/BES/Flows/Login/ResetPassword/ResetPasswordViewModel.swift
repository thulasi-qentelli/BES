//
//  ResetPasswordViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ResetPasswordViewModel{
    
    let besService = BESService()
    var didSendEmail : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func resetPasswordFor(_ inputEmail:String){
        
        besService.resetPasswordFor(inputEmail)
            .done{ user in
                print(user)
                self.didSendEmail.accept(true)
            }.catch{ error in
                print(error)
                self.didSendEmail.accept(false)
        }
    }
    
}
