//
//  LoginViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameView: InputView!
    @IBOutlet weak var passwordView: InputView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var createAccountBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        userNameView.getUpdatedText = { string in
            if string.isValidEmail() {
                self.userNameView.accessoryImgView.isHidden = false
            }
            else {
                self.userNameView.accessoryImgView.isHidden = true
            }
        }
        
        passwordView.getUpdatedText = { string in
            if string.count >= 6 {
                self.passwordView.accessoryImgView.isHidden = false
            }
            else {
                self.passwordView.accessoryImgView.isHidden = true
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupUI() {
        forgotPasswordBtn.titleLabel?.numberOfLines = 1
        forgotPasswordBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        createAccountBtn.titleLabel?.numberOfLines = 1
        createAccountBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        userNameView.titleLbl.text = "Username"
        userNameView.txtField.placeholder = "Enter email"
        userNameView.txtField.keyboardType = .emailAddress
        
        passwordView.titleLbl.text = "Password"
        passwordView.txtField.placeholder = "Enter password"
        passwordView.txtField.isSecureTextEntry = true
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnAction(_ sender: UIButton) {
        
        
        
        if sender == signInBtn {
            guard let email = userNameView.txtField.text else {
                self.view.makeToast("Please enter user name", duration: 1.0, position: .center)
                userNameView.txtField.becomeFirstResponder()
                return
            }
            guard let password = passwordView.txtField.text else {
                self.view.makeToast("Please enter password", duration: 1.0, position: .center)
                passwordView.txtField.becomeFirstResponder()
                return
            }
            
            if email.count <= 0 {
                self.view.makeToast("Please enter user name", duration: 1.0, position: .center)
                userNameView.txtField.becomeFirstResponder()
                return
            }
            
            if !email.isValidEmail() {
                self.view.makeToast("Please enter a vaild email address", duration: 1.0, position: .center)
                userNameView.txtField.becomeFirstResponder()
                return
            }
            
            if password.count < 6 {
                self.view.makeToast("Please enter password", duration: 1.0, position: .center)
                passwordView.txtField.becomeFirstResponder()
                return
            }
            
            var parameters = ParameterDetail()
            parameters.email = email
            parameters.password = password
            
            if let parm = parameters.dictionary {
                let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Please wait"
                
                NetworkManager().post(method: .login, parameters: parm) { (result, error) in
                    DispatchQueue.main.async {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        if error != nil {
                            self.view.makeToast(error, duration: 2.0, position: .center)
                            return
                        }
                        
                        AppController.shared.user = result as? User
                        saveUserDetails(user: result as! User)
                        AppController.shared.loadHomeView()
                    }
                }
                
            }

            
        }
        else if sender == forgotPasswordBtn {
            let forgotVC = ForgotPWDViewController()
            self.navigationController?.pushViewController(forgotVC, animated: true)
        }
        else if sender == createAccountBtn {
            let signupVC = SignupViewController()
            self.navigationController?.pushViewController(signupVC, animated: true)
        }
        
    }
    
}
