//
//  ForgotPasswordViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ForgotPasswordViewController: UIViewController {
    
    fileprivate var viewModel : ForgotPasswordViewModel!
    fileprivate var router : ForgotPasswordRouter!
    let disposeBag            = DisposeBag()
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var btnSendLink : UIButton!
    @IBOutlet weak var txtEmail : UITextField!
    
    init(with viewModel:ForgotPasswordViewModel,_ router:ForgotPasswordRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "ForgotPasswordViewController", bundle: nil)
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
        
        btnSendLink.layer.cornerRadius = 4
        btnSendLink.clipsToBounds = true
        
        btnBack.addTarget(self, action: #selector(close), for: .touchUpInside)
        btnSendLink.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
    }
    
    @objc func close(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpRx(){
        
        viewModel.didSendEmail.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                self.activityIndicator.stopAnimating()
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.router.navigateToResetPassword()
                
            }).disposed(by: disposeBag)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50 //keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func forgotPassword(){
        
        validationCheck()
    }

    func validationCheck(){
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        guard let email = txtEmail.text else{
            
            self.showAlertWith(title: "BES", message: "Please Enter Email", action: "OK")
            return
        }
        
        guard  !email.isEmpty else{
            
            self.showAlertWith(title: "BES", message: "Please Enter Email", action: "OK")
            return
        }
        
        self.activityIndicator.startAnimating()
        self.viewModel.resetPasswordFor(email)
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}
