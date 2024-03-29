//
//  SignupViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignupViewController: UIViewController {

    
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    @IBOutlet weak var firstNameView: InputView!
    @IBOutlet weak var lastNameView: InputView!
    @IBOutlet weak var emailView: InputView!
    @IBOutlet weak var passwordView: InputView!
    @IBOutlet weak var confirmPasswordView: InputView!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    
    var imagePickerOne: ImagePicker!
    var imageURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        profileHeaderView.profileImageTapped = {
            self.imagePickerOne.present(from: self.profileHeaderView.profileImgView)
        }
        firstNameView.getUpdatedText = { string in
            self.firstNameView.accessoryImgView.isHidden = true
            if string.isValidName() {
                self.firstNameView.accessoryImgView.isHidden = false
            }
        }
        lastNameView.getUpdatedText = { string in
            self.lastNameView.accessoryImgView.isHidden = true
            if string.isValidName() {
                self.lastNameView.accessoryImgView.isHidden = false
            }
        }
        
        emailView.txtField.textContentType = .username
        emailView.txtField.keyboardType = .emailAddress
        
        emailView.getUpdatedText = { string in
            self.emailView.accessoryImgView.isHidden = true
            if string.isValidEmail(){
                self.emailView.accessoryImgView.isHidden = false
            }
        }
        passwordView.txtField.textContentType = .password
        passwordView.getUpdatedText = { string in
            if string.count > 0  {
                self.passwordView.accessoryImgBtn.isHidden = false
                self.passwordView.accessoryImgView.isHidden = false
            }
            else {
                self.passwordView.accessoryImgBtn.isHidden = true
                self.passwordView.accessoryImgView.isHidden = true
            }
        }
        passwordView.accessoryAction = { sender in
            self.passwordView.txtField.isSecureTextEntry = sender.isSelected
            self.passwordView.txtField.clearsOnBeginEditing = false
            sender.isSelected = !sender.isSelected
            
        }
        
        confirmPasswordView.txtField.textContentType = .password
        confirmPasswordView.getUpdatedText = { string in
            if string.count > 0 {
                self.confirmPasswordView.accessoryImgBtn.isHidden = false
                self.confirmPasswordView.accessoryImgView.isHidden = false
            }
            else {
                self.confirmPasswordView.accessoryImgBtn.isHidden = true
                self.confirmPasswordView.accessoryImgView.isHidden = true
            }
        }
        confirmPasswordView.accessoryAction = { sender in
            self.confirmPasswordView.txtField.isSecureTextEntry = sender.isSelected
            self.confirmPasswordView.txtField.clearsOnBeginEditing = false
            sender.isSelected = !sender.isSelected
            
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
        
        self.imagePickerOne = ImagePicker(presentationController: self, delegate: self, destructiveNeeded: false)
        
        firstNameView.titleLbl.text = "First Name"
        firstNameView.txtField.placeholder = "Enter First Name"
        
        lastNameView.titleLbl.text = "Last Name"
        lastNameView.txtField.placeholder = "Enter Last Name"
        
        emailView.titleLbl.text = "Email"
        emailView.txtField.placeholder = "Enter Email"
        emailView.txtField.keyboardType = .emailAddress
        
        passwordView.titleLbl.text = "Password"
        passwordView.txtField.placeholder = "Enter Password"
        passwordView.txtField.isSecureTextEntry = true
        passwordView.txtField.clearsOnBeginEditing = false
        confirmPasswordView.titleLbl.text = "Confirm Password"
        confirmPasswordView.txtField.placeholder = "Confirm Password"
        confirmPasswordView.txtField.isSecureTextEntry = true
        confirmPasswordView.txtField.clearsOnBeginEditing = false
    }
    @IBAction func btnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == signInBtn {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if sender == createAccountBtn {
            if validateData() {
                
                let firstName = firstNameView.txtField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
                let lastName = lastNameView.txtField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
                let email = emailView.txtField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
                let password = passwordView.txtField.text!.trimmingCharacters(in: NSCharacterSet.whitespaces)
                
                var parameters = ParameterDetail()
                parameters.firstName = firstName
                parameters.lastName = lastName
                parameters.email = email
                parameters.password = password
                parameters.role = "user"
                
                if let parm = parameters.dictionary {
                    let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                    loadingNotification.mode = MBProgressHUDMode.indeterminate
                    loadingNotification.label.text = "Please wait.."
                    
                    NetworkManager().post(method: .saveUser, parameters: parm, isURLEncode: false) { (result, error) in
                        DispatchQueue.main.async {
                            if error != nil {
                                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                                self.view.makeToast(error, duration: 2.0, position: .center)
                                return
                            }
                            
                            if let user = result as? User {
                               self.checkAndUploadImage(user: user)
                            }
                            else {
                                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                                self.view.makeToast("Unknown error occured while signup. Please try later.", duration: 2.0, position: .center)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkAndUploadImage(user:User) {
        if self.imageURL != nil  {
            NetworkManager().uploadImage(method: .uploadImage, parameters: ["id": "\(user.id!)"], image: self.profileHeaderView.profileImgView.image!, completion: { (imgResult, imgError) in
                DispatchQueue.main.async {
                    if imgError != nil {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        self.view.makeToast("Profile picture upload failed. Please try update later.", duration: 2.0, position: .center)
                    }
                    self.callSendEmail()
                }
            })
        }
        else {
            self.callSendEmail()
        }
    }
    
    func callSendEmail() {
        let email = emailView.txtField.text!
        
        NetworkManager().post(method: .sendEmail, parameters: ["email" : email, "content" : "bes/activeUser?email=\(email)", "type" : "signup"]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                let alertVC     =   AcknowledgeViewController()
                alertVC.type    =   .Signup
                alertVC.email   =   email
                self.navigationController?.pushViewController(alertVC, animated: true)
            }
        }
    }
    
    func validateData() -> Bool {
        
        guard let firstName = firstNameView.txtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please enter first name", duration: 1.0, position: .center)
            firstNameView.txtField.becomeFirstResponder()
            return false
        }
        guard let lastName = lastNameView.txtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please enter last name", duration: 1.0, position: .center)
            lastNameView.txtField.becomeFirstResponder()
            return false
        }
        guard let email = emailView.txtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please enter email", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        guard let password = passwordView.txtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        guard let confirmPassword = confirmPasswordView.txtField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please confirm password", duration: 1.0, position: .center)
            confirmPasswordView.txtField.becomeFirstResponder()
            return false
        }
        
//        guard let url = imageURL else {
//            self.view.makeToast("Please upload profile picture", duration: 1.0, position: .center)
//            return false
//        }
        if !firstName.isValidName() {
            self.view.makeToast("Please enter valid first name", duration: 1.0, position: .center)
            firstNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if !lastName.isValidName(){
            self.view.makeToast("Please enter valid last name", duration: 1.0, position: .center)
            lastNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if email.count < 1{
            self.view.makeToast("Please enter email", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        
        if !email.isValidEmail() {
            self.view.makeToast("Please enter vaild email address", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return false
        }
        
        if !password.isValidPassword() {
            self.view.makeToast("Password must contain atleast 1 lowercase and 1 uppercase alphabetical character, 1 numeric character, 1 special character(!@#$*) and must be eight characters or longer", duration: 2.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        
        if !confirmPassword.isValidPassword() {
            self.view.makeToast("Please confirm password", duration: 1.0, position: .center)
            confirmPasswordView.txtField.becomeFirstResponder()
            return false
        }
        
        if password != confirmPassword {
            self.view.makeToast("Passwords doesn't match", duration: 1.0, position: .center)
            confirmPasswordView.txtField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
}

extension SignupViewController: ImagePickerDelegate {
    func removeImage() {
        
    }
    
    func didSelect(image: UIImage?) {
        if let kImage = image {
            self.profileHeaderView.profileImgView.image = image
            self.profileHeaderView.profileImgPlaceholderView.isHidden = true
            self.imageURL = "Saved"
        }
    }
}
