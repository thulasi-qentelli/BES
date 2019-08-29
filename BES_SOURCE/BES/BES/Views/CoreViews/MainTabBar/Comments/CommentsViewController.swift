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
    let cellReuseIdendifier = "CommentsTableViewCell"
    var keys:[String] = []
    let refreshControl = UIRefreshControl()
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
       // self.loadComments(showLoader: true)
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
            dic[$0] = filterArray//.sorted(){$0.timeShortForm < $1.timeShortForm}
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
            
//        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
//        if #available(iOS 10.0, *) {
//            self.tblView.refreshControl = refreshControl
//        } else {
//            self.tblView.backgroundView = refreshControl
//        }
        
        
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
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        self.refreshControl.endRefreshing()
        loadComments(showLoader: true)
    }
    
    func loadComments(showLoader:Bool) {
        if showLoader {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
            self.noDataLbl.isHidden = true
        }
        
        NetworkManager().get(method: .getMessagesByEmail, parameters: ["email" : AppController.shared.user?.email ?? ""]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.refreshControl.endRefreshing()
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    if self.commentsSource.count == 0{
                        self.noDataLbl.isHidden = false
                    }
                    else {
                        self.noDataLbl.isHidden = true
                    }
                    return
                }
                
                if let _ = result, let kmess = (result as? [Comment]),kmess.count > 0 {
                    
                    let datesArray = kmess.compactMap { $0.dateShortForm }
                    var dic = [String:[Comment]]()
                    datesArray.forEach {
                        let dateKey = $0
                        let filterArray = kmess.filter { $0.dateShortForm == dateKey }
                        dic[$0] = filterArray//.sorted(){$0.timeShortForm < $1.timeShortForm}
                    }
                    let keysArr = dic.keys
                    self.commentsSource = kmess
                    self.keys =  keysArr.sorted().reversed()
                    self.comments = dic
                    self.tblView.reloadData()
                }
                else {
                    self.keys = []
                    self.commentsSource = []
                    self.comments = [:]
                    self.tblView.reloadData()
                    self.noDataLbl.isHidden = false
                }
            }
        }
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
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 30))
        titleLabel.text = self.comments[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = self.view.tintColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! CommentsTableViewCell
        
        cell.messageLbl.text = self.comments[self.keys[indexPath.section]]?[indexPath.row].comment
        cell.timeStampLbl.text = self.comments[self.keys[indexPath.section]]?[indexPath.row].createdDate?.date?.displayTime
        
        if let urlString = self.comments[self.keys[indexPath.section]]?[indexPath.row].userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.profileImgView.sd_setImage(with:url, completed: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}


