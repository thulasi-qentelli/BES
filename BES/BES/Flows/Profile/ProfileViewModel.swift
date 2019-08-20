//
//  ProfileViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel{
    
    let besService = BESService()
    var didGetStates : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var didUpdateUser : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var locations = [String]()
    
    func updateWith(id inputId:Int,firstName inputFirstName:String,lastName inputLastName:String,email inputEmail:String,password inputPassword:String,location inputLocation:String){
        
        besService.updateuser(id:inputId,firstName: inputFirstName, lastName: inputLastName, email: inputEmail, password: inputPassword,location: inputLocation)
            .done{ user in
                print(user)
                self.didUpdateUser.accept(true)
            }.catch{ error in
                print(error)
                self.didUpdateUser.accept(false)
        }
    }
    
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
    
    func uploadImage(_ inputImage:UIImage,identifier:String){
        besService.upload(image: inputImage,identifier: identifier)
            .done{ success in
                    print("uploaded successfully")
             }.catch{ error in
                    print(error)
                    print("Failed")
        }
    }
    
    
}


