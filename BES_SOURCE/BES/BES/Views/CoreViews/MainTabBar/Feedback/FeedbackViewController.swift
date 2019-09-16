//
//  FeedbackViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import DropDown
import MBProgressHUD

class FeedbackViewController: UIViewController {

    @IBOutlet weak var categoryView: InputView!
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var commentsView: CommentInputView!
    var gobackHome:()->Void = {
        
    }
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
        ratingView.selectedRating = 0
        commentsView.txtView.text = ""
        
      
        
        categoryView.accessoryImgView.isHidden  =   false
        categoryView.accessoryImgBtn.isHidden = false
        categoryView.accessoryAction = { sender in
            self.view.endEditing(true)
            self.categoryDropDown.dataSource = self.categories
            self.categoryDropDown.show()
        }
        
        getCategories()
        
    }
    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.logoutAction()
    }
    
    
    func setupUI() {
                
        self.categoryDropDown.anchorView = self.categoryView.anchorRefView
        self.categoryDropDown.textColor = UIColor.black
        self.categoryDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.categoryDropDown.backgroundColor = UIColor.white
        self.categoryDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.categoryDropDown.cellHeight = 60
        self.categoryDropDown.cornerRadius = 10
        
        self.categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.categoryView.txtField.text = item
        }
    }
    
    func getCategories() {
        NetworkManager().get(method: .getCategories, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                self.categories = (result as! [Category]).map{$0.service?.trimmingCharacters(in: NSCharacterSet.whitespaces) ?? ""}
                self.categories = self.categories.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                self.categoryDropDown.dataSource = self.categories
            }
        }
        self.categoryDropDown.dataSource = self.categories
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        guard let category = categoryView.txtField.text else {
            self.view.makeToast("Please select feedback type", duration: 1.0, position: .center)
            return
        }
        
        if category.count <= 0 {
            self.view.makeToast("Please select feedback type", duration: 1.0, position: .center)
            return
        }
        
        if self.ratingView.selectedRating == 0 {
            self.view.makeToast("Please rate your service / experience.", duration: 1.0, position: .center)
            return
        }
        
        guard let comments = commentsView.txtView.text?.trimmingCharacters(in: NSCharacterSet.whitespaces) else {
            self.view.makeToast("Please add your comments", duration: 1.0, position: .center)
            commentsView.txtView.becomeFirstResponder()
            return
        }
        
        if comments.count <= 0 {
            self.view.makeToast("Please add your comments", duration: 1.0, position: .center)
            commentsView.txtView.becomeFirstResponder()
            return
        }
        
        var parameters = ParameterDetail()
        parameters.useremail = AppController.shared.user?.email
        parameters.category = category
        parameters.content = comments
        parameters.rating = "\(ratingView.selectedRating)"
        
        if let parm = parameters.dictionary {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
            
            NetworkManager().post(method: .saveFeedback, parameters: parm, isURLEncode: false) { (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if error != nil {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                        return
                    }
                    
                    self.categoryView.txtField.text = ""
                    self.ratingView.selectedRating = 0
                    self.commentsView.txtView.text = ""
                    
                    let alertVC     =   AcknowledgeViewController()
                    alertVC.type    =   .Feedback
                    alertVC.gobackHome = {
                        self.gobackHome()
                    }
                    self.navigationController?.pushViewController(alertVC, animated: true)
                }
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        categoryView.txtField.text = ""
        ratingView.selectedRating = 0
        commentsView.txtView.text = ""
    }
    
}


