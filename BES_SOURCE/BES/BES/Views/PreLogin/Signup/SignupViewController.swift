//
//  SignupViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    @IBOutlet weak var firstNameView: InputView!
    @IBOutlet weak var lastNameView: InputView!
    @IBOutlet weak var emailView: InputView!
    @IBOutlet weak var passwordView: InputView!
    @IBOutlet weak var confirmPasswordView: InputView!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        firstNameView.getUpdatedText = { string in
            self.firstNameView.accessoryImgView.isHidden = true
            if string.count > 0 {
                self.firstNameView.accessoryImgView.isHidden = false
            }
        }
        lastNameView.getUpdatedText = { string in
            self.lastNameView.accessoryImgView.isHidden = true
            if string.count > 0 {
                self.lastNameView.accessoryImgView.isHidden = false
            }
        }
        
        emailView.getUpdatedText = { string in
            self.emailView.accessoryImgView.isHidden = true
            if string.isValidEmail(){
                self.emailView.accessoryImgView.isHidden = false
            }
        }
        
        passwordView.getUpdatedText = { string in
            self.passwordView.accessoryImgView.isHidden = true
            self.confirmPasswordView.accessoryImgView.isHidden = true
            if string.count >= 6 {
                self.passwordView.accessoryImgView.isHidden = false
                if string == self.confirmPasswordView.txtField.text {
                    self.confirmPasswordView.accessoryImgView.isHidden = false
                }
            }
        }
        confirmPasswordView.getUpdatedText = { string in
            self.confirmPasswordView.accessoryImgView.isHidden = true
            if string.count >= 6, string == self.passwordView.txtField.text {
                self.confirmPasswordView.accessoryImgView.isHidden = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = false
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.navigationItem.titleView = imageView
        
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "arrow_back"), for: .normal)
        backbutton.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: backbutton)

        let currWidth = barButton.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = barButton.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = barButton
        
        
        
    }


    
    @objc func backBtnAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setupUI() {
        
        firstNameView.titleLbl.text = "First Name"
        firstNameView.txtField.placeholder = "Enter first name"
        
        lastNameView.titleLbl.text = "Last Name"
        lastNameView.txtField.placeholder = "Enter last name"
        
        emailView.titleLbl.text = "Email address"
        emailView.txtField.placeholder = "Enter email address"
        emailView.txtField.keyboardType = .emailAddress
        
        passwordView.titleLbl.text = "Password"
        passwordView.txtField.placeholder = "Enter password"
        passwordView.txtField.isSecureTextEntry = true
        
        confirmPasswordView.titleLbl.text = "Confirm password"
        confirmPasswordView.txtField.placeholder = "Confirm password"
        confirmPasswordView.txtField.isSecureTextEntry = true
 
    }
    @IBAction func btnAction(_ sender: UIButton) {
        if sender == signInBtn {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if sender == createAccountBtn {
            if validateData() {
                
                let alertVC     =   AcknowledgeViewController()
                alertVC.type    =   .Signup
                alertVC.email   =   emailView.txtField.text ?? ""
                self.navigationController?.pushViewController(alertVC, animated: true)
                return
                
                
                let firstName = firstNameView.txtField.text!
                let lastName = lastNameView.txtField.text!
                let email = emailView.txtField.text!
                let password = passwordView.txtField.text!
                
                var parameters = ParameterDetail()
                parameters.firstName = firstName
                parameters.lastName = lastName
                parameters.email = email
                parameters.password = password
                parameters.role = "user"
                parameters.pic = ""
                
                if let parm = parameters.dictionary {
                    NetworkManager().post(method: .saveUser, parameters: parm) { (result, error) in
                        DispatchQueue.main.async {
                            if error != nil {
                                self.view.makeToast(error, duration: 2.0, position: .center)
                                return
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    func validateData() -> Bool {
        
        guard let firstName = firstNameView.txtField.text else {
            self.view.makeToast("Please enter first name", duration: 1.0, position: .center)
            firstNameView.txtField.becomeFirstResponder()
            return false
        }
        guard let lastName = lastNameView.txtField.text else {
            self.view.makeToast("Please enter last name", duration: 1.0, position: .center)
            lastNameView.txtField.becomeFirstResponder()
            return false
        }
        guard let email = emailView.txtField.text else {
            self.view.makeToast("Please enter email", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        guard let password = passwordView.txtField.text else {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        guard let confirmPassword = confirmPasswordView.txtField.text else {
            self.view.makeToast("Please confirm password", duration: 1.0, position: .center)
            confirmPasswordView.txtField.becomeFirstResponder()
            return false
        }
        
        if firstName.count < 1 {
            self.view.makeToast("Please enter first name", duration: 1.0, position: .center)
            firstNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if lastName.count < 1 {
            self.view.makeToast("Please enter last name", duration: 1.0, position: .center)
            lastNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if email.count <= 0 {
            self.view.makeToast("Please enter email", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        
        if !email.isValidEmail() {
            self.view.makeToast("Please enter a vaild email address", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        
//        if password.count < 6 {
//            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
//            passwordView.txtField.becomeFirstResponder()
//            return false
//        }
//        
//        if confirmPassword.count < 6 || password != confirmPassword {
//            self.view.makeToast("Please confirm password", duration: 1.0, position: .center)
//            confirmPasswordView.txtField.becomeFirstResponder()
//            return false
//        }
        
        return true
    }
    
   
    
}
