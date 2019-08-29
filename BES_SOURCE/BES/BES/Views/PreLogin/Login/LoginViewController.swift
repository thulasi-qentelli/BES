//
//  LoginViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD
import Security

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
        //Username text update
        userNameView.getUpdatedText = { string in
            if string.isValidEmail() {
                self.userNameView.accessoryImgView.isHidden = false
            }
            else {
                self.userNameView.accessoryImgView.isHidden = true
            }
        }

        //Password text update
        passwordView.getUpdatedText = { string in
            if string.count > 0 {
                self.passwordView.accessoryImgBtn.isHidden = false
                self.passwordView.accessoryImgView.isHidden = false
            }
            else {
                self.passwordView.accessoryImgBtn.isHidden = true
                self.passwordView.accessoryImgView.isHidden = true
            }
        }
        //password eye action
        passwordView.accessoryAction = { sender in
            self.passwordView.txtField.isSecureTextEntry = sender.isSelected
            sender.isSelected = !sender.isSelected
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupUI() {
        userNameView.txtField.keyboardType = .emailAddress
        userNameView.txtField.textContentType = .username
        userNameView.txtField.keyboardType = .emailAddress
        passwordView.txtField.isSecureTextEntry = true
        passwordView.txtField.textContentType = .password
        
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
                self.view.endEditing(true)
        if sender == signInBtn {
            if validateData() {
                self.loginService()
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
    
    
    func loginService() {
        let email = self.userNameView.txtField.text!
        let password = self.passwordView.txtField.text!
        
        SecAddSharedWebCredential("http://besconnect.qentelli.com:8081" as CFString, email as CFString, password as CFString) { (error) in
            print(error?.localizedDescription)
            
            DispatchQueue.main.async {
                var parameters = ParameterDetail()
                parameters.email = email
                parameters.password = password
                
                if let parm = parameters.dictionary {
                    let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                    loadingNotification.mode = MBProgressHUDMode.indeterminate
                    loadingNotification.label.text = "Please wait.."
                    
                    NetworkManager().post(method: .login, parameters: parm) { (result, error) in
                        DispatchQueue.main.async {
                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                            if error != nil {
                                self.view.makeToast(error, duration: 2.0, position: .center)
                                return
                            }
                            
                            AppController.shared.user = result as? User
                            saveAuthToken(token: AppController.shared.user!.token!)
                            saveUserDetails(user: result as! User)
                            AppController.shared.loadStartView()
                        }
                    }
                }
            }
        }
    }
    
    func validateData()->Bool {
        
        guard let email = userNameView.txtField.text else {
            self.view.makeToast("Please enter user name", duration: 1.0, position: .center)
            userNameView.txtField.becomeFirstResponder()
            return false
        }
        guard let password = passwordView.txtField.text else {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        
        if email.count <= 0 {
            self.view.makeToast("Please enter user name", duration: 1.0, position: .center)
            userNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if !email.isValidEmail() {
            self.view.makeToast("Please enter a vaild email address", duration: 1.0, position: .center)
            userNameView.txtField.becomeFirstResponder()
            return false
        }
        
        if password.count < 6 {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        return true
    }
    
}
