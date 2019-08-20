//
//  EnquiryViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import DropDown

class EnquiryViewController: UIViewController {
    
    fileprivate var viewModel : EnquriyViewModel!
    fileprivate var router    : EnquiryRouter!
    let disposeBag = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var btnSelectCategory : UIButton!
    @IBOutlet weak var btnSelectLocation : UIButton!
    @IBOutlet weak var selectCategoryView : UIView!
    @IBOutlet weak var selectLocationView : UIView!
    @IBOutlet weak var phoneNumberView : UIView!
    @IBOutlet weak var txtVwEnquiry : UITextView!
    @IBOutlet weak var btnSubmit : UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var btnProfile : UIButton!
    @IBOutlet weak var lblCountryCode : UILabel!
    @IBOutlet weak var lblCommentCount : UILabel!
    
    var categoryDropDown  = DropDown()
    var locationDropDown  = DropDown()
    
    init(with viewModel:EnquriyViewModel,_ router:EnquiryRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "EnquiryViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        headerView.dropShadow()

        viewModel.getLocations()
        viewModel.getCategories()
        
        
        btnSubmit.layer.cornerRadius = 4
        btnSubmit.clipsToBounds = true
        
        txtVwEnquiry.delegate = self
        txtVwEnquiry.layer.cornerRadius = 4
        txtVwEnquiry.layer.borderWidth = 1
        txtVwEnquiry.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        selectCategoryView.layer.cornerRadius = 4
        selectCategoryView.layer.borderWidth = 1
        selectCategoryView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        selectLocationView.layer.cornerRadius = 4
        selectLocationView.layer.borderWidth = 1
        selectLocationView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        lblCountryCode.layer.cornerRadius = 4
        phoneNumberView.layer.cornerRadius = 4
        phoneNumberView.layer.borderWidth = 1
        phoneNumberView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        if let userImage = appDelegate.user?.pic{
            var urlString = userImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url  = URL(string: urlString!){
                self.btnProfile.imageView!.sd_setImage(with:url){
                    image,error,cache,d in
                    if let unwrappedImage = image{
                        self.btnProfile.setImage(unwrappedImage, for: .normal)
                    }
                }
            }
        }
        btnCancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        btnSubmit.addTarget(self, action: #selector(sendEnquiry), for: .touchUpInside)
        
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.clipsToBounds  = true
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        
        
        categoryDropDown.offsetFromWindowBottom = 300
        categoryDropDown.anchorView = btnSelectCategory
        self.categoryDropDown.width = self.selectCategoryView.frame.width-20
        self.categoryDropDown.textColor = UIColor.black
        self.categoryDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.categoryDropDown.backgroundColor = UIColor.white
        self.categoryDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.categoryDropDown.cellHeight = 60
        self.categoryDropDown.cornerRadius = 10
        self.btnSelectCategory.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
        self.categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnSelectCategory.setTitle(item, for: .normal)
        }
        
        
        locationDropDown.offsetFromWindowBottom = 300
        locationDropDown.anchorView = btnSelectLocation
        
        self.locationDropDown.width = self.selectLocationView.frame.width-20
        self.locationDropDown.textColor = UIColor.black
        self.locationDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.locationDropDown.backgroundColor = UIColor.white
        self.locationDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.locationDropDown.cellHeight = 60
        self.locationDropDown.cornerRadius = 10
        self.btnSelectLocation.addTarget(self, action: #selector(showLocationDropDown), for: .touchUpInside)
        self.locationDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnSelectLocation.setTitle(item, for: .normal)
        }
        
        setupRX()
    }
    
    func setupRX(){
        
        viewModel.didGetStates.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{return}
                
                self.locationDropDown.dataSource = self.viewModel.locations
               
                
            }).disposed(by: disposeBag)
        
        viewModel.didGetCategories.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{return}
                
                self.categoryDropDown.dataSource = self.viewModel.categories
                
            }).disposed(by: disposeBag)
        
        viewModel.didSendEnquiry.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                let alertVC = UIAlertController(title: "Success", message:"Request Sent.", preferredStyle: .alert)
                let okAction = UIAlertAction(title:"OK", style: .default, handler:{ action in
                    self.dismiss(animated: true, completion: nil)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func showDropDown(){
        
        self.categoryDropDown.show()
    }
    
    @objc func showLocationDropDown(){
        
        self.locationDropDown.show()
    }

    @objc func cancel(){
        
        self.router.navigateToCommunicationViewController()
    }
    
    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
    
    @objc func sendEnquiry(){
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        guard let user = appDelegate.user,let userEmail = user.email else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        guard let comments = self.txtVwEnquiry.text,let category = btnSelectCategory.titleLabel!.text,let location = btnSelectLocation.titleLabel!.text,let number = txtPhoneNumber.text else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        guard !comments.isEmpty,!category.isEmpty,!location.isEmpty,!number.isEmpty,location.lowercased().trimmingCharacters(in: .whitespaces) != "select location",category.lowercased().trimmingCharacters(in: .whitespaces) != "select category" else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        
        
        self.viewModel.sendEnquiry(comments: comments, phoneNumber: number, location: location, category: category, email: userEmail)
    }

}

extension EnquiryViewController : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        let lettersCount = String((textView.text.count))
        lblCommentCount.text = "\(lettersCount)/400"
        return true
    }
    
}
