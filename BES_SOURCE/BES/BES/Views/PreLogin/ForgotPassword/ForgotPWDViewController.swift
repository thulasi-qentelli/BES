//
//  ForgotPWDViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit

class ForgotPWDViewController: UIViewController {

    @IBOutlet weak var emailView: InputView!
    @IBOutlet weak var sendLinkBtn: UIButton!
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
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
        emailView.titleLbl.text = "Email address"
        emailView.txtField.placeholder = "Enter email address"
        
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
        
        if sender == sendLinkBtn {
            let alertVC     =   AcknowledgeViewController()
            alertVC.type    =   .ForgotPassword
            self.navigationController?.pushViewController(alertVC, animated: true)
        }
        else if sender == resendBtn {

            let alertVC     =   AcknowledgeViewController()
            alertVC.type    =   .ForgotPassword
            self.navigationController?.pushViewController(alertVC, animated: true)
        }
        else if sender == backBtn {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
