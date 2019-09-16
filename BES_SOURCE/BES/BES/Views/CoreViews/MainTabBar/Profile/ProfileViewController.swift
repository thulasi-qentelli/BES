//
//  SignupViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 21/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var profileHeaderView: ProfileHeaderView!
    @IBOutlet weak var firstNameView: InputView!
    @IBOutlet weak var lastNameView: InputView!
    @IBOutlet weak var locationView: InputView!
    @IBOutlet weak var emailView: InputView!
    @IBOutlet weak var passwordView: InputView!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    var locations:[String] = []
    let locationDropDown = DropDown()
    
    var imagePickerOne: ImagePicker!
    var imageURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        

        profileHeaderView.user  = AppController.shared.user
        
        profileHeaderView.profileImageTapped = {
            self.imagePickerOne.present(from: self.profileHeaderView.profileImgView)
        }
        
        profileHeaderView.profileSubIcon.image = UIImage(named: "EditProfileImage")
//        profileHeaderView.profileSubIcon.backgroundColor = UIColor.gray
        
        firstNameView.accessoryImgView.isHidden  =   false
        firstNameView.accessoryImgBtn.isHidden = false
        firstNameView.getUpdatedText = { string in
            self.firstNameView.accessoryImgView.isHidden = true
            if string.count > 0 {
                self.firstNameView.accessoryImgView.isHidden = false
            }
        }
        lastNameView.accessoryImgView.isHidden  =   false
        lastNameView.accessoryImgBtn.isHidden = false
        lastNameView.getUpdatedText = { string in
            self.lastNameView.accessoryImgView.isHidden = true
            if string.count > 0 {
                self.lastNameView.accessoryImgView.isHidden = false
            }
        }
        
        locationView.accessoryImgView.isHidden  =   false
        locationView.accessoryImgBtn.isHidden = false
        locationView.accessoryAction = { sender in
            self.view.endEditing(true)
            self.locationDropDown.dataSource = self.locations
            self.locationDropDown.show()
        }
        emailView.accessoryImgView.isHidden  =   false
        emailView.accessoryImgBtn.isHidden = false
        emailView.txtField.textColor = UIColor.lightGray
        emailView.txtField.isEnabled = false
        emailView.actionBtn.isEnabled = false
        emailView.getUpdatedText = { string in
            self.emailView.accessoryImgView.isHidden = true
            if string.isValidEmail(){
                self.emailView.accessoryImgView.isHidden = false
            }
        }
        passwordView.accessoryImgView.isHidden  =   false
        passwordView.accessoryImgBtn.isHidden = false
        
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
        passwordView.accessoryAction = { sender in
            self.passwordView.txtField.isSecureTextEntry = sender.isSelected
            self.passwordView.txtField.clearsOnBeginEditing = false
            sender.isSelected = !sender.isSelected
        }
        
        getLocations()
       
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


    func getLocations() {
        NetworkManager().get(method: .getStates, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                self.locations = (result as! [State]).map{$0.statename?.trimmingCharacters(in: NSCharacterSet.whitespaces) ?? ""}
                self.locations = self.locations.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                self.locationDropDown.dataSource = self.locations
            }
        }
        self.locationDropDown.dataSource = self.locations
    }
    
    @objc func backBtnAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        
        self.imagePickerOne = ImagePicker(presentationController: self, delegate: self, destructiveNeeded: true)
        
        firstNameView.titleLbl.text = "First Name"
        firstNameView.txtField.placeholder = "Enter first name"
        
        lastNameView.titleLbl.text = "Last Name"
        lastNameView.txtField.placeholder = "Enter last name"
        
        locationView.titleLbl.text = "Location"
        locationView.txtField.placeholder = "EnterLocation"
        
        emailView.titleLbl.text = "Email address"
        emailView.txtField.placeholder = "Enter email address"
        emailView.txtField.keyboardType = .emailAddress
        
        passwordView.titleLbl.text = "Password"
        passwordView.txtField.placeholder = "Enter password"
        passwordView.txtField.isSecureTextEntry = true
        self.passwordView.txtField.clearsOnBeginEditing = false
        profileHeaderView.textLbl.text = "UPDATE PROFILE\nPICTURE"
        
        if let user = AppController.shared.user {
            firstNameView.txtField.text = user.firstName
            lastNameView.txtField.text = user.lastName
            locationView.txtField.text = user.location
            emailView.txtField.text = user.email
            passwordView.txtField.text = user.password
        }
        
        
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
 
    }
    @IBAction func btnAction(_ sender: UIButton) {
        if sender == signInBtn {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if sender == createAccountBtn {
            if validateData() {
                self.view.endEditing(true)
                let firstName = firstNameView.txtField.text!
                let lastName = lastNameView.txtField.text!
                let location = locationView.txtField.text!
                let email = emailView.txtField.text!
                let password = passwordView.txtField.text!
                
                var parameters = ParameterDetail()
                parameters.id = "\(AppController.shared.user?.id ?? 0)"
                parameters.firstName = firstName
                parameters.lastName = lastName
                parameters.email = email
                parameters.password = password
                parameters.role = AppController.shared.user?.role
                parameters.location = location
                parameters.pic = AppController.shared.user?.pic
                
                if let url = self.imageURL, url == "" {
                    parameters.pic = ""
                }
                
                if let parm = parameters.dictionary {
                    let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                    loadingNotification.mode = MBProgressHUDMode.indeterminate
                    loadingNotification.label.text = "Please wait.."

                    NetworkManager().put(method: .updateUser, parameters: parm, isURLEncode: false) { (result, error) in
                        DispatchQueue.main.async {
                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                            if error != nil {
                                self.view.makeToast(error, duration: 2.0, position: .center)
                                return
                            }
                            
                            if let url = self.imageURL, url == "Saved" {
                                if let user = result as? User {
                                    let loadingNotification1 = MBProgressHUD.showAdded(to: self.view, animated: true)
                                    loadingNotification1.mode = MBProgressHUDMode.indeterminate
                                    loadingNotification1.label.text = "Please wait.."
                                    NetworkManager().uploadImage(method: .uploadImage, parameters: ["id": "\(user.id!)"], image: self.profileHeaderView.profileImgView.image!, completion: { (imgResult, imgError) in
                                        DispatchQueue.main.async {
                                            
                                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                                            if imgError != nil {
                                                self.view.makeToast("Profile picture upload failed. Please try update later.", duration: 2.0, position: .center)
                                                return
                                            }
                                            
                                            AppController.shared.user = user
                                            self.getAuthUser(user: user)
                                            
                                            self.view.makeToast("User profile updated successfully.", duration: 2.0, position: .center)
                                        }
                                    })
                                }
                            }
                            else {
                                if let user = result as? User {
                                    AppController.shared.user = user
                                    self.getAuthUser(user: user)
                                }
                                
                                self.view.makeToast("User profile updated successfully.", duration: 2.0, position: .center)
                            }
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    func getAuthUser(user:User) {
        var parameters = ParameterDetail()
        parameters.email = user.email
        parameters.password = user.password
        
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
        
        guard let location = locationView.txtField.text else {
            return false
        }
        guard let password = passwordView.txtField.text else {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
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
        
        if password.count < 6 {
            self.view.makeToast("Please enter password", duration: 1.0, position: .center)
            passwordView.txtField.becomeFirstResponder()
            return false
        }
        
        return true
    }

}

extension ProfileViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        if let kImage = image {
            self.profileHeaderView.profileImgView.image = image
            self.profileHeaderView.profileImgPlaceholderView.isHidden = true
            self.imageURL = "Saved"
        }
    }
    
    func removeImage() {
        self.imageURL = ""
        
//        self.btnAction(createAccountBtn)
//        AppController.shared.user = AppController.shared.user
        self.profileHeaderView.profileImgView.image = nil
        self.profileHeaderView.profileImgPlaceholderView.isHidden = false
    }
}


