//
//  ResetPasswordViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ResetPasswordViewController: UIViewController {
    
    fileprivate var viewModel : ResetPasswordViewModel!
    fileprivate var router    : ResetPasswordRouter!
    let disposeBag            = DisposeBag()
    
    @IBOutlet weak var activityIndicator : UIActivityIndicatorView!
    @IBOutlet weak var btnSignIn : UIButton!
    @IBOutlet weak var btnResend : UIButton!
    var emailId : String!
    
    
    init(with viewModel:ResetPasswordViewModel,_ router:ResetPasswordRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "ResetPasswordViewController", bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupViews()
       setUpRx()
    }

    func setupViews(){
        
        btnSignIn.layer.cornerRadius = 4
        btnSignIn.clipsToBounds = true
        
        btnSignIn.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        btnResend.addTarget(self, action: #selector(resend), for: .touchUpInside)
    }
    
    func setUpRx(){
        
        viewModel.didSendEmail.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                self.activityIndicator.stopAnimating()
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.showAlertWith(title: "Success", message: "Email Sent Successfully.", action: "OK")
                
            }).disposed(by: disposeBag)
    }

    @objc func signIn(){
        
        self.router.navigateToSignIn()
    }
    
    @objc func resend(){
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        if let emailId = self.emailId{
            self.activityIndicator.startAnimating()
            self.viewModel.resetPasswordFor(emailId)
        }
        
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
 
}
