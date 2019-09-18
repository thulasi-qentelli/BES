//
//  CommentsViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage
import IQKeyboardManager

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var feed:Feed?
    var commentsSource:[Comment] = []
    var comments: [String:[Comment]] = [:]
    let cellReuseIdendifier = "CommentsTableViewCell1"
    var keys:[String] = []
    
    
    @IBOutlet weak var commentsBottomConst: NSLayoutConstraint!
    @IBOutlet weak var commentsInputView: CommentFieldView!
    
    var commentesAdded:(Feed)-> Void = { comments in
        
    }

    @IBOutlet weak var noDataLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        if self.commentsSource.count > 0 {
            self.noDataLbl.isHidden = true
          
            self.filterCommentsAndReload()
        }
        
        commentsInputView.getUpdatedText = { text in
            if text.count > 0 {
                
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Please wait.."
                
                self.view.endEditing(true)
                var parameters = ParameterDetail()
                parameters.comment = text
                parameters.postId = "\(self.feed!.id!)"
                parameters.email = "\(AppController.shared.user!.email!)"
                
                if let parm = parameters.dictionary {
                    NetworkManager().post(method: .saveComment, parameters:parm,isURLEncode: false , completion: { (result, error) in
                        DispatchQueue.main.async {
                            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        
                            if error != nil {
                                self.view.makeToast(error, duration: 2.0, position: .center)
                                return
                            }
                            self.noDataLbl.isHidden = true
                            self.commentsInputView.txtField.text = ""
                            if (result as? Comment) != nil {
                                let comment = result as! Comment
                                comment.userName = AppController.shared.user?.getName().capitalized
                                self.feed?.comments?.append(result as! Comment)
                                self.commentsSource = self.feed!.comments!
                                self.filterCommentsAndReload()
                            }
                            self.commentesAdded(self.feed!)
                        }
                    })
                }
            }
            else {
                self.view.makeToast("Please enter comment.", duration: 2.0, position: .center)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.commentsBottomConst.constant = keyboardHeight
            self.view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
      
            self.commentsBottomConst.constant = 0
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        IQKeyboardManager.shared().isEnabled = true
        NotificationCenter.default.removeObserver(self)
    }
    
    func filterCommentsAndReload() {
        let datesArray = self.commentsSource.compactMap { $0.dateShortForm }
        var dic = [String:[Comment]]()
        datesArray.forEach {
            let dateKey = $0
            let filterArray = self.commentsSource.filter { $0.dateShortForm == dateKey }
            
            var isNewName = true
            var name = ""
            for i in 0..<filterArray.count {
                
                let messs = filterArray[i]
                if isNewName == true {
                    name = messs.userName ?? ""
                    isNewName = false
                    messs.isNameRequired = true
                }
                
                if name != messs.userName ?? ""{
                    name = messs.userName ?? ""
                    messs.isNameRequired = true
                }
            }
            
            dic[$0] = filterArray
        }
        let keysArr = dic.keys
        self.keys =  keysArr.sorted()
        self.comments = dic
        self.tblView.reloadData()
        
        if self.keys.count>0 {
            
            let kcomments = self.comments[self.keys[self.keys.count - 1]]
        
            let indexPath = NSIndexPath(row: kcomments!.count - 1, section: self.keys.count - 1)
            self.tblView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
           
           
        } else {
            self.tblView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
    }
    @objc func backBtnAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.logoutAction()
    }

    func setupUI() {
        self.tblView.estimatedRowHeight = 60
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.register(UINib.init(nibName: cellReuseIdendifier, bundle: nil), forCellReuseIdentifier: cellReuseIdendifier)
        
        IQKeyboardManager.shared().isEnabled = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        self.commentsInputView.backgroundColor = self.view.backgroundColor
    }
}


extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments[self.keys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 30))
        titleLabel.text = self.comments[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate
        titleLabel.backgroundColor = UIColor(red: 222.0/255.0, green: 242.0/255.0, blue: 249.0/255.0, alpha: 1)
        
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        let width = (self.comments[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate.widthOfString(usingFont: titleLabel.font) ?? 0) + 20
        
        if width <= UIScreen.main.bounds.size.width - 60 {
            titleLabel.frame.size.width = width
        }
        
        //        titleLabel.textColor = self.view.tintColor
        titleLabel.textColor = UIColor.darkGray
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.center = CGPoint(x: view.center.x, y: 20)
        titleLabel.layer.cornerRadius = 6
        titleLabel.layer.masksToBounds = true
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! CommentsTableViewCell1
        
        if let message = self.comments[self.keys[indexPath.section]]?[indexPath.row] {
            cell.setupCell(comment: message)
           
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}


