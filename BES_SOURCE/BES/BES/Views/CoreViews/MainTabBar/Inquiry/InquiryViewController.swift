//
//  InquiryViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD

class InquiryViewController: UIViewController {

    @IBOutlet weak var categoryView: InputView!
    @IBOutlet weak var locationView: InputView!
    @IBOutlet weak var phoneView: MobileNumberView!
    @IBOutlet weak var commentsView: CommentInputView!
    
    var locations:[String] = []
    let locationDropDown = DropDown()
    
    var categories:[String] = []
    let categoryDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
        
        categoryView.txtField.text = ""
        locationView.txtField.text = ""
        phoneView.txtField.text = ""
        commentsView.txtView.text = ""
        
        locationView.accessoryImgView.isHidden  =   false
        locationView.accessoryImgBtn.isHidden = false
        locationView.accessoryAction = { sender in
            self.view.endEditing(true)
            self.locationDropDown.dataSource = self.locations
            self.locationDropDown.show()
        }
        
        categoryView.accessoryImgView.isHidden  =   false
        categoryView.accessoryImgBtn.isHidden = false
        categoryView.accessoryAction = { sender in
            self.view.endEditing(true)
            self.categoryDropDown.dataSource = self.categories
            self.categoryDropDown.show()
        }
        
        phoneView.getUpdatedText = { string in
            
            print(string)
            
            if let number = Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                // Do something with this number
                print(number)
            }
        }
        
        getLocations()
        getCategories()
        
    }
    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.logoutAction()
    }
    
    
    func setupUI() {

        self.locationDropDown.anchorView = self.locationView.txtField
        self.locationDropDown.textColor = UIColor.black
        self.locationDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.locationDropDown.backgroundColor = UIColor.white
        self.locationDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.locationDropDown.cellHeight = 60
        self.locationDropDown.cornerRadius = 10
        self.locationDropDown.width = UIScreen.main.bounds.size.width - 60
        self.locationDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.locationView.txtField.text = item
        }
        
        self.categoryDropDown.anchorView = self.categoryView.txtField
        self.categoryDropDown.textColor = UIColor.black
        self.categoryDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.categoryDropDown.backgroundColor = UIColor.white
        self.categoryDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.categoryDropDown.cellHeight = 60
        self.categoryDropDown.cornerRadius = 10
        self.categoryDropDown.width = UIScreen.main.bounds.size.width - 60
        self.categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.categoryView.txtField.text = item
        }
        
    }
    
    func getLocations() {
        NetworkManager().get(method: .getStates, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                self.locations = (result as! [State]).map{$0.statename?.trimmingCharacters(in: NSCharacterSet.whitespaces) ?? ""}
                self.locationDropDown.dataSource = self.locations.sorted()
            }
        }
        self.locationDropDown.dataSource = self.locations.sorted()
    }
    
    func getCategories() {
        NetworkManager().get(method: .getCategories, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                self.categories = (result as! [Category]).map{$0.service?.trimmingCharacters(in: NSCharacterSet.whitespaces) ?? ""}
                self.categoryDropDown.dataSource = self.categories.sorted()
            }
        }
        self.categoryDropDown.dataSource = self.categories.sorted()
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        guard let category = categoryView.txtField.text else {
            self.view.makeToast("Please select category", duration: 1.0, position: .center)
            return
        }
        
        if category.count <= 0 {
            self.view.makeToast("Please select category", duration: 1.0, position: .center)
            return
        }
        guard let state = locationView.txtField.text else {
            self.view.makeToast("Please select location", duration: 1.0, position: .center)
            return
        }
        
        if state.count <= 0 {
            self.view.makeToast("Please select location", duration: 1.0, position: .center)
            return
        }
        
        guard let phone = phoneView.txtField.text else {
            self.view.makeToast("Please enter phone number", duration: 1.0, position: .center)
            phoneView.txtField.becomeFirstResponder()
            return
        }
        
        guard let comments = commentsView.txtView.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please add your comments", duration: 1.0, position: .center)
            commentsView.txtView.becomeFirstResponder()
            return
        }
        
        guard let number = Int(phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) else{
            // Do something with this number
            self.view.makeToast("Please enter valid phone number", duration: 1.0, position: .center)
            phoneView.txtField.becomeFirstResponder()
            return
        }
        
        if "\(number)".count != 10 {
            self.view.makeToast("Please enter valid phone number", duration: 1.0, position: .center)
            phoneView.txtField.becomeFirstResponder()
            return
        }
        
        if comments.count <= 0 {
            self.view.makeToast("Please add your comments", duration: 1.0, position: .center)
            commentsView.txtField.becomeFirstResponder()
            return
        }
        
        var parameters = ParameterDetail()
        parameters.email = AppController.shared.user?.email
        parameters.location = state
        parameters.category = category
        parameters.comments = comments
        parameters.phonenumber = "\(number)"
        
        if let parm = parameters.dictionary {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
            
            NetworkManager().post(method: .saveInquiry, parameters: parm, isURLEncode: false) { (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if error != nil {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                        return
                    }
                    
                    self.categoryView.txtField.text = ""
                    self.locationView.txtField.text = ""
                    self.phoneView.txtField.text = ""
                    self.commentsView.txtView.text = ""
                    
                    let alertVC     =   AcknowledgeViewController()
                    alertVC.type    =   .Inquiry
                    self.navigationController?.pushViewController(alertVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        categoryView.txtField.text = ""
        locationView.txtField.text = ""
        phoneView.txtField.text = ""
        commentsView.txtView.text = ""
    }
    
    
}


