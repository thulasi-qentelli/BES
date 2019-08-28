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

class CommentsViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var feed:Feed?
    var commentsSource:[Comment] = []
    var comments: [String:[Comment]] = [:]
    let cellReuseIdendifier = "CommentsTableViewCell"
    var keys:[String] = []
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var noDataLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        if self.commentsSource.count > 0 {
            self.noDataLbl.isHidden = true
            let datesArray = self.commentsSource.compactMap { $0.dateShortForm }
            var dic = [String:[Comment]]()
            datesArray.forEach {
                let dateKey = $0
                let filterArray = self.commentsSource.filter { $0.dateShortForm == dateKey }
                dic[$0] = filterArray//.sorted(){$0.timeShortForm < $1.timeShortForm}
            }
            let keysArr = dic.keys
            self.keys =  keysArr.sorted().reversed()
            self.comments = dic
            self.tblView.reloadData()
        }
        
       // self.loadComments(showLoader: true)
        
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
            
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            self.tblView.refreshControl = refreshControl
        } else {
            self.tblView.backgroundView = refreshControl
        }
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


