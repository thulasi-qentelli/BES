//
//  ForgotPWDViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPWDViewController: UIViewController {

    @IBOutlet weak var emailView: InputView!
    @IBOutlet weak var sendLinkBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        emailView.txtField.keyboardType = .emailAddress
        emailView.getUpdatedText = { string in
            if string.isValidEmail() {
                self.emailView.accessoryImgView.isHidden = false
            }
            else {
                self.emailView.accessoryImgView.isHidden = true
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
        
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        guard let email = emailView.txtField.text else {
            self.view.makeToast("Please enter email address", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return
        }
        
        if email.count <= 0 {
            self.view.makeToast("Please enter email address", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return
        }
        
        if !email.isValidEmail() {
            self.view.makeToast("Please enter a vaild email address", duration: 1.0, position: .center)
            emailView.txtField.becomeFirstResponder()
            return
        }
        print(email)
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Please wait.."
        
        if sender == sendLinkBtn {
            NetworkManager().post(method: .sendEmail, parameters: ["email" : email, "content" : "http://besconnect.qentelli.com:8085/#/resetpassword/\(email)", "type" : "forgot"]) { (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if error != nil {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                        return
                    }
                    
                    let alertVC     =   AcknowledgeViewController()
                    alertVC.type    =   .ForgotPassword
                    self.navigationController?.pushViewController(alertVC, animated: true)
                }
            }
            
        }
        else {
            NetworkManager().post(method: .sendEmail, parameters: ["email" : email, "content" : "bes/activeUser?email=\(email)", "type" : "signup"]) { (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if error != nil {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                        return
                    }
                    
                    self.view.makeToast(result as? String, duration: 2.0, position: .center)
                }
            }
        }
        
        
        /*
        if sender == sendLinkBtn {
            
        var parameters = ParameterDetail()
        parameters.email = email
        parameters.path = "resetpassword/\(email)"
        
            if let parm = parameters.dictionary {
                let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Please wait.."
                
                NetworkManager().post(method: .forgotPassword, parameters: parm, isURLEncode: true) { (result, error) in
                    DispatchQueue.main.async {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        if error != nil {
                            self.view.makeToast(error, duration: 2.0, position: .center)
                            return
                        }
                        
                        let alertVC     =   AcknowledgeViewController()
                        alertVC.type    =   .ForgotPassword
                        self.navigationController?.pushViewController(alertVC, animated: true)
                    }
                }
                
            }
        }
        else {
            NetworkManager().post(method: .sendEmail, parameters: ["email" : email, "content" : "bes/activeUser?email=\(email)", "forgot" : "signup"]) { (result, error) in
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                
                self.view.makeToast(result as? String, duration: 2.0, position: .center)
            }
        }
         */
 
    }
}
