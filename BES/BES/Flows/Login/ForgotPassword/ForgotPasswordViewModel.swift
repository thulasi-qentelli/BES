//
//  ForgotPasswordViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ForgotPasswordViewModel{
    
    let besService = BESService()
    var didSendEmail : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    func resetPasswordFor(_ inputEmail:String){
        
        besService.resetPasswordFor(inputEmail)
            .done{ success in
                print(success)
                self.didSendEmail.accept(true)
            }.catch{ error in
                print(error)
                self.didSendEmail.accept(false)
        }
    }
}
