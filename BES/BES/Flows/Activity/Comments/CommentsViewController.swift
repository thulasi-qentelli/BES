//
//  CommentsViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentsViewController: UIViewController {
    
    fileprivate var viewModel : CommentsViewModel!
    fileprivate var router    : CommentsRouter!
    let disposeBag = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnCancel : UIButton!
    @IBOutlet weak var tblComments : UITableView!
    @IBOutlet weak var txtAddYourComment : UITextField!
   
    let commentsCellReuseIdentifier = "CommentsCellReuseIdentifer"
    var comments = [Comment]()
    var postID : Int?
    
    init(with viewModel:CommentsViewModel,router:CommentsRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "CommentsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.dropShadow()
        self.hideKeyboard()
        
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
        
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.clipsToBounds = true
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        btnCancel.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        tblComments.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: commentsCellReuseIdentifier)
        tblComments.delegate = self
        tblComments.dataSource = self
        tblComments.tableFooterView = UIView()
        
        btnSend.layer.cornerRadius = 4
        btnSend.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        
        setUpRx()
    }
    
    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height+50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func sendComment(){
        
        if txtAddYourComment.text == nil{
            return
        }
        

        self.viewModel.sendComment(with: txtAddYourComment.text!,for: self.postID!)
    }

    @objc func close(){
        
        self.router.close()
    }
    
    func setUpRx(){
        
        viewModel.didSendComment.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let firstName = appDelegate.user!.firstName!
                let lastName = appDelegate.user!.lastName!
                let userName = firstName+" "+lastName
                let comment = Comment(id: nil, userName: userName, email: nil, comment: self.txtAddYourComment.text!, createdDate: nil, updatedDate: nil, like: nil, postId: nil)
                self.txtAddYourComment.text = nil
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.comments.append(comment)
                self.tblComments.reloadData()
                
            }).disposed(by: disposeBag)
    }

    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    

}

extension CommentsViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentsCellReuseIdentifier, for: indexPath) as! CommentsTableViewCell
        
        let currentComment = self.comments[indexPath.row]
        cell.configure(with: currentComment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
