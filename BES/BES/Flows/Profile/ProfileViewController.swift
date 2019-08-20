//
//  ProfileViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import DropDown
import MBProgressHUD


class ProfileViewController: UIViewController {
    
    fileprivate var viewModel : ProfileViewModel!
    fileprivate var router    : ProfileRouter!
    let disposeBag = DisposeBag()
    
    var imagePickerOne: ImagePicker!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txtFirstName : UITextField!
    @IBOutlet weak var txtLastName : UITextField!
    @IBOutlet weak var btnFirstNameEdit : UIButton!
    @IBOutlet weak var btnLastNameEdit : UIButton!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblLocation : UILabel!
    @IBOutlet weak var txtUsername : UITextField!
    @IBOutlet weak var txtEmail : UITextField!
 
    @IBOutlet weak var txtPassword : UITextField!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnEdit : UIButton!
    @IBOutlet weak var btnLocationEdit : UIButton!
    @IBOutlet weak var btnPasswordEdit : UIButton!
    @IBOutlet weak var btnLocation : UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imagePicker = UIImagePickerController()
    var imageURL : String?
    let locationDropDown = DropDown()
    
    init(with viewModel:ProfileViewModel,_ router:ProfileRouter){
        
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: "ProfileViewController", bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        setupRx()
        setUpProfile()
        
         self.imagePickerOne = ImagePicker(presentationController: self, delegate: self)
    }

    func setUpViews(){
        
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.viewModel.getLocations()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.clipsToBounds = true
        
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        btnEdit.addTarget(self, action: #selector(edit), for: .touchUpInside)
        btnPasswordEdit.addTarget(self, action: #selector(editPassword), for: .touchUpInside)
        btnLocationEdit.addTarget(self, action: #selector(editLocation), for: .touchUpInside)
        btnFirstNameEdit.addTarget(self, action: #selector(editFirstName), for: .touchUpInside)
        btnLastNameEdit.addTarget(self, action: #selector(editLastName), for: .touchUpInside)
        
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        //profileImageView.addGestureRecognizer(tapGesture)
        
        
        self.locationDropDown.anchorView = self.btnLocation
        self.locationDropDown.textColor = UIColor.black
        self.locationDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.locationDropDown.backgroundColor = UIColor.white
        self.locationDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.locationDropDown.cellHeight = 60
        self.locationDropDown.cornerRadius = 10
        self.locationDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnLocation.setTitle(item, for: .normal)
        }
        locationDropDown.offsetFromWindowBottom = 300
        btnLocation.isEnabled = false
        btnLocation.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
        
        btnLogout.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
    }
    
    @objc func showDropDown(){
        
        self.locationDropDown.show()
    }
    
    func setupRx(){
        
        
        viewModel.didGetStates.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{return}
                
                self.locationDropDown.dataSource = self.viewModel.locations
                
                
            }).disposed(by: disposeBag)
        
        viewModel.didUpdateUser.skip(1).asObservable()
            .subscribe(onNext:{ success in
               
                self.activityIndicator.stopAnimating()
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return }
                
                self.setUpProfile()
                
            }).disposed(by: disposeBag)
        
        viewModel.didUpdateProfileImage.skip(1).asObservable()
            .subscribe(onNext:{ success in
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return }
                
                self.setUpProfile()
                
            }).disposed(by: disposeBag)
        
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func logout(){
        
        let alertVC = UIAlertController(title: "Logout", message:"Are you sure you want to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"Cancel", style: .default, handler:{ action in
            self.dismiss(animated: true, completion: nil)
        })
        let okAction = UIAlertAction(title:"Ok", style: .default, handler:{ action in
           self.showSignIn()
        })
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showSignIn(){

        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "SavedMessages")

        let signInVC = SignInBuilder.viewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = signInVC
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 200 //keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
   
    
    @objc func changeImage(){
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.delegate = self;
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.delegate = self;
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    @objc func close(){
        
        self.router.close()
    }
    
    @objc func edit(){
        
        guard btnEdit.titleLabel?.text == "Edit" else{
            
            self.btnEdit.setTitle("Edit", for: .normal)
            
            self.btnLocation.backgroundColor = UIColor.white
            self.btnLocationEdit.isHidden = true
            self.btnLocationEdit.setTitle("Edit", for: .normal)
            
            self.txtPassword.backgroundColor = UIColor.white
            self.btnPasswordEdit.isHidden = true
            self.btnPasswordEdit.setTitle("Edit", for: .normal)
            
            self.txtFirstName.backgroundColor = UIColor.white
            self.btnFirstNameEdit.isHidden = true
            self.btnFirstNameEdit.setTitle("Edit", for: .normal)
            
            self.txtLastName.backgroundColor = UIColor.white
            self.btnLastNameEdit.isHidden = true
            self.btnLocationEdit.setTitle("Edit", for: .normal)
            
            
            self.updateUser()
            return
        }
        
        self.btnEdit.setTitle("Done", for: .normal)
        self.btnLocationEdit.isHidden = false
        self.btnPasswordEdit.isHidden = false
        self.btnFirstNameEdit.isHidden = false
        self.btnLastNameEdit.isHidden = false
    }
    
    func updateUser(){
        
        let user = appDelegate.user!
        
        guard let firstName = txtFirstName.text,let lastName = txtLastName.text,let location = btnLocation.titleLabel!.text,let password = txtPassword.text else{
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return
        }
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        self.activityIndicator.startAnimating()
        self.viewModel.updateWith(id: user.id!, firstName:txtFirstName.text!, lastName: txtLastName.text!, email: user.email!, password: txtPassword.text!,location: btnLocation.titleLabel!.text!)
        
        if let url = self.imageURL {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Updating profile.."
            
            self.viewModel.uploadImage(self.profileImageView.image!, identifier: "\(user.id!)")
        }
        
    }
    
    @objc func editPassword(){
        
        guard btnPasswordEdit.titleLabel?.text == "Edit" else{
            
            self.txtPassword.backgroundColor = UIColor.white
            self.txtPassword.isEnabled = false
            self.txtPassword.becomeFirstResponder()
            self.btnPasswordEdit.setTitle("Edit", for: .normal)
            return
        }
        
        self.txtPassword.backgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.txtPassword.becomeFirstResponder()
        self.txtPassword.isEnabled = true
        self.btnPasswordEdit.setTitle("Done", for: .normal)
    }
    
    @objc func editLocation(){
        
        guard btnLocationEdit.titleLabel?.text == "Edit" else{
            
            self.btnLocation.backgroundColor = UIColor.white
            self.btnLocation.isEnabled = false
            self.btnLocationEdit.setTitle("Edit", for: .normal)
            return
        }
        
        self.btnLocation.backgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.btnLocation.isEnabled = true
        self.btnLocationEdit.setTitle("Done", for: .normal)
    }
    
    @objc func editFirstName(){
        
        guard btnFirstNameEdit.titleLabel?.text == "Edit" else{
            
            self.txtFirstName.backgroundColor = UIColor.white
            self.txtFirstName.isEnabled = false
            self.btnFirstNameEdit.setTitle("Edit", for: .normal)
            return
        }
        
        self.txtFirstName.backgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.txtFirstName.becomeFirstResponder()
        self.txtFirstName.isEnabled = true
        self.btnFirstNameEdit.setTitle("Done", for: .normal)
    }
    
    @objc func editLastName(){
        
        guard btnLastNameEdit.titleLabel?.text == "Edit" else{
            
            self.txtLastName.backgroundColor = UIColor.white
            self.txtLastName.isEnabled = false
            self.btnLastNameEdit.setTitle("Edit", for: .normal)
            return
        }
        
        self.txtLastName.backgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.txtLastName.becomeFirstResponder()
        self.txtLastName.isEnabled = true
        self.btnLastNameEdit.setTitle("Done", for: .normal)
    }
    
    func setUpProfile(){
        
        guard let currentUser = appDelegate.user else { return }
        
        guard let firstName = currentUser.firstName,let lastName = currentUser.lastName else { return }
        lblName.text     = firstName + " " + lastName
        txtUsername.text = firstName + " " + lastName
        txtFirstName.text = firstName
        txtLastName.text = lastName
        
        if let location = currentUser.location{
            btnLocation.setTitle(location, for: .normal)
            lblLocation.text = location
        }
        
        if let userImage = appDelegate.user?.pic{
            var urlString = userImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url  = URL(string: urlString!){
                self.profileImageView.sd_setImage(with:url, completed: nil)
            }
            
        }
        
        guard let email = currentUser.email else {return}
        txtEmail.text = email
        
        guard let password = currentUser.password else { return }
        txtPassword.text = password
    }
    @IBAction func profileImageTapped(_ sender: UIButton) {
        self.imagePickerOne.present(from: sender)
    }
}
extension ProfileViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        
        self.profileImageView.image = image
        self.imageURL = "Saved"
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          picker.dismiss(animated: true, completion: nil)
          guard let image = info[.originalImage] as? UIImage else {
              fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
          }
          self.profileImageView.image = image
          self.imageURL = "Saved"
    }
}
