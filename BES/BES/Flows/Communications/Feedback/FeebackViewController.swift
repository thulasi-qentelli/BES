//
//  FeebackViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DropDown

class FeebackViewController: UIViewController {
    
    fileprivate var viewModel : FeedbackViewModel!
    fileprivate var router    : FeedbackRouter!
    let disposeBag = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnSelectCategory: UIButton!
    @IBOutlet weak var lblRemarks: UILabel!
    @IBOutlet weak var selectCategoryView : UIView!
    @IBOutlet weak var txtvwFeeback : UITextView!
    @IBOutlet weak var btnSubmit : UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var btnProfile : UIButton!
    
    @IBOutlet weak var btn1 : UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3 : UIButton!
    @IBOutlet weak var btn4 : UIButton!
    @IBOutlet weak var btn5 : UIButton!
    var allStars : [UIButton]!
    var rating   : Int = 0
    var categoryDropDown = DropDown()
    
    init(with viewModel:FeedbackViewModel,_ router:FeedbackRouter){
        
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: "FeebackViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       viewModel.getCategories()
       self.setupViews()
       self.setupRx()
    }

    func setupViews(){
        
        self.hideKeyboard()
        headerView.dropShadow()
        
        btnSubmit.layer.cornerRadius = 4
        btnSubmit.clipsToBounds = true
        
        txtvwFeeback.delegate = self
        txtvwFeeback.layer.cornerRadius = 4
        txtvwFeeback.layer.borderWidth = 1
        txtvwFeeback.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        selectCategoryView.layer.cornerRadius = 4
        selectCategoryView.layer.borderWidth = 1
        selectCategoryView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        categoryDropDown.offsetFromWindowBottom = 300
        categoryDropDown.anchorView = btnSelectCategory
        btnSelectCategory.addTarget(self, action: #selector(showDropDown), for: .touchUpInside)
        
        btnCancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
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
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        btnSubmit.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.clipsToBounds = true
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        
        allStars = [btn1,btn2,btn3,btn4,btn5]
        
        btn1.tag = 0
        btn2.tag = 1
        btn3.tag = 2
        btn4.tag = 3
        btn5.tag = 4
        
        for eachButton in allStars{
            eachButton.addTarget(self, action: #selector(rating(sender:)), for: .touchUpInside)
        }
        
    
        self.categoryDropDown.width = self.selectCategoryView.frame.width-20
        self.categoryDropDown.textColor = UIColor.black
        self.categoryDropDown.textFont = UIFont.systemFont(ofSize: 15)
        self.categoryDropDown.backgroundColor = UIColor.white
        self.categoryDropDown.selectionBackgroundColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1)
        self.categoryDropDown.cellHeight = 60
        self.categoryDropDown.cornerRadius = 10
        self.categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnSelectCategory.setTitle(item, for: .normal)
        }
        
    }
    
    func setupRx(){
        
        viewModel.didSendFeedback.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                let alertVC = UIAlertController(title: "Success", message:"Feedback Sent.", preferredStyle: .alert)
                let okAction = UIAlertAction(title:"OK", style: .default, handler:{ action in
                    self.dismiss(animated: true, completion: nil)
                })
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                
            }).disposed(by: disposeBag)
        
        viewModel.didGetCategories.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{return}
                
                self.categoryDropDown.dataSource = self.viewModel.categories
                
            }).disposed(by: disposeBag)
    }
    
    @objc func rating(sender:UIButton){
        
        let activeImage = UIImage(named: "rating_active")
        let inactiveImage = UIImage(named: "rating_inactive")
        
        let button = allStars[sender.tag]
        if button.imageView?.image == activeImage{
            
            for i in sender.tag+1...allStars.count-1{
                
                let button = allStars[i]
                button.setImage(inactiveImage, for: .normal)
            }
            
        }else{
            
            for i in 0...sender.tag{
                
                let button = allStars[i]
                button.setImage(activeImage, for: .normal)
            }
        }
    }
    
    @objc func showDropDown(){
        
        self.categoryDropDown.show()
    }
  
    @objc func cancel(){
        
        self.router.navigateToCommunicationViewController()
    }
    
    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
    
    @objc func sendFeedback(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        guard let user = appDelegate.user,let userEmail = user.email else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        guard let content = self.txtvwFeeback.text,let category = btnSelectCategory.titleLabel!.text else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        guard !content.isEmpty,!category.isEmpty,category.lowercased().trimmingCharacters(in: .whitespaces) != "select category" else {
            self.showAlertWith(title: "BES", message: "All fields are mandatory", action: "Ok")
            return}
        
        var rating = allStars.filter{$0.imageView?.image == UIImage(named: "rating_active")}
        
        self.viewModel.sendFeedback(content:content, rating: rating.count, category:category, email:userEmail)
    }
    

    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}

extension FeebackViewController : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        let lettersCount = String((textView.text.count))
        lblRemarks.text = "\(lettersCount)/400"
        return true
    }
    
}


