//
//  SignUpViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    
    fileprivate var viewModel : SignUpViewModel!
    fileprivate var router    : SignUpRouter!
    let disposeBag            = DisposeBag()
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var firstName : UITextField!
    @IBOutlet weak var lastName  : UITextField!
    @IBOutlet weak var email  : UITextField!
    @IBOutlet weak var password  : UITextField!
    @IBOutlet weak var confirmPassword  : UITextField!
    
    
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnSignUp : UIButton!
    
    init(with viewModel:SignUpViewModel,_ router:SignUpRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "SignUpViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        setUpViews()
        setUpRx()
    }

    func setUpViews(){
        
        btnSignUp.layer.cornerRadius = 4
        btnSignUp.clipsToBounds = true
        
        btnSignIn.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        btnSignUp.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        btnBack.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc func close(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpRx(){
        
        viewModel.didUserSignUp.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
            self.activityIndicator.stopAnimating()
                
            guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return }
            
            self.router.navigateToVerification()
                
        }).disposed(by: disposeBag)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 150 //keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
   
    @objc func signUp(){
        
        validationCheck()
    }
    
    @objc func signIn(){
        
        self.router.navigateToSignIn()
    }
    
    func validationCheck(){
        
        guard let firstName = firstName.text,let lastName = lastName.text,let email = email.text,let password = password.text,let confirmPassword = confirmPassword.text else{
            
            self.showAlertWith(title: "BES", message: "All Fields Are Mandatory", action: "OK")
            return
        }
        
        guard !firstName.isEmpty,!lastName.isEmpty,!email.isEmpty,!password.isEmpty,!confirmPassword.isEmpty else{
            
            self.showAlertWith(title: "BES", message: "All Fields Are Mandatory", action: "OK")
            return
        }
        
        guard password == confirmPassword else{
            
            self.showAlertWith(title: "BES", message: "Given Passwords Donot Match", action: "OK")
            return
        }
        
        self.activityIndicator.startAnimating()
        viewModel.signUpWith(firstName: firstName,lastName: lastName,email: email,password: password)
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}
