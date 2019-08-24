//
//  AcknowledgeViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
enum AcknowledgeType {
    case Signup
    case ForgotPassword
}
class AcknowledgeViewController: UIViewController {

    var type:AcknowledgeType = .ForgotPassword
    var email:String = ""
    @IBOutlet weak var clickHereHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var alertImageView: UIImageView!
    @IBOutlet weak var alertTitleLbl: UILabel!
    @IBOutlet weak var alertDetailLbl: UILabel!
    @IBOutlet weak var clickHereBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
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
        switch type {
        case .ForgotPassword:
            titleLbl.text = "Forgot\nPassword?"
            alertTitleLbl.text = "Password reset sent"
            alertDetailLbl.text = "We've emailed you the instructions for setting your password, if an account exists with the email you entered\n\nIf you didn't receive an email, please make sure you've entered the email address you registered with, and check your spam folder."
            clickHereHeightConstraint.constant = 0
            doneBtn.setTitle("DONE", for: .normal)
        case .Signup:
            titleLbl.text = "New\nAccount"
            alertTitleLbl.text = "Email Verification Required"
            alertDetailLbl.text = "Am email has been sent to:\n\(self.email)\n\nPlease follow the instructions in the verification email to finish creating your BES account."
            doneBtn.setTitle("DONE", for: .normal)
     
        }
    }
    @IBAction func btnAction(_ sender: UIButton) {
        if sender == clickHereBtn {
            
        }
        else if sender == doneBtn {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}
