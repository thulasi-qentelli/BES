//
//  InquiryViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import DropDown

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
        
        getLocations()
        getCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
        
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
        
        self.categoryDropDown.anchorView = self.locationView.txtField
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
        categoryView.txtField.text = ""
        locationView.txtField.text = ""
        phoneView.txtField.text = ""
        commentsView.txtView.text = ""
        
        let alertVC     =   AcknowledgeViewController()
        alertVC.type    =   .Inquiry
        self.navigationController?.pushViewController(alertVC, animated: true)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        categoryView.txtField.text = ""
        locationView.txtField.text = ""
        phoneView.txtField.text = ""
        commentsView.txtView.text = ""
    }
}


