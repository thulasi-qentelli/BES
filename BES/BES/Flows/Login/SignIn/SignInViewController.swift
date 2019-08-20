//
//  SignInViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Security


class SignInViewController: UIViewController {
    
    fileprivate let viewModel : SignInViewModel!
    fileprivate let router    : SignInRouter!
    let disposeBag            = DisposeBag()
    
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var btnForgotPassword : UIButton!
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnSignUp : UIButton!
    

    init(with viewModel:SignInViewModel,_ router:SignInRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "SignInViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        setupViews()
        setUpRx()
    }
    
    func setupViews(){
      
        txtEmail.layer.borderWidth = 0
        txtEmail.layer.borderColor = UIColor.clear.cgColor
        txtEmail.textContentType = .username
        
        txtPassword.layer.borderColor = UIColor.clear.cgColor
        txtPassword.textContentType = .password
        
        btnSignIn.layer.cornerRadius = 4
        btnSignIn.clipsToBounds = true
        
        
        btnSignIn.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        btnSignUp.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        btnForgotPassword.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 100 //keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }


    @objc func signIn(){
        
        validationCheck()
    }
    
    @objc func signUp(){
        
        self.router.navigateToSignUp()
    }
    
    @objc func forgotPassword(){
        
        self.router.navigateToForgotPassword()
    }
    
    func setUpRx(){
        
        viewModel.didGetUser.skip(1).asObservable()
            .subscribe(onNext:{ success in
    
            self.activityIndicator.stopAnimating()
    
            guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
            
                self.router.navigateToFeed()
                
        }).disposed(by: disposeBag)
        
    }
    
    func validationCheck(){
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        guard let email = self.txtEmail.text,let password = self.txtPassword.text else{
            
            self.showAlertWith(title:"BES",message: "All Fields Are Mandatory", action: "OK")
            return
        }
        
        guard !email.isEmpty, !password.isEmpty else{
            
            self.showAlertWith(title:"BES",message: "All Fields Are Mandatory", action: "OK")
            return
        }
        
        SecAddSharedWebCredential("bes.qentelli.com:8085" as CFString, email as CFString, password as CFString) { (error) in
            print(error?.localizedDescription)
            DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.viewModel.loginWith(username: email, password: password)
            }
        }        
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
   
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
