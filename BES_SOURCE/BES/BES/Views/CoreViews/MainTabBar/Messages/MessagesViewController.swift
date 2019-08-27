//
//  MessagesViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage

class MessagesViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var messages: [String:[Message]] = [:]
    let cellReuseIdendifier = "MessageTableViewCell"
    var keys:[String] = []
    let refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        self.loadMessages(showLoader: true)
        
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
        loadMessages(showLoader: true)
    }
    
    func loadMessages(showLoader:Bool) {
        if showLoader {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
        }
        
        NetworkManager().get(method: .getMessagesByEmail, parameters: ["email" : AppController.shared.user?.email ?? ""]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.refreshControl.endRefreshing()
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                
                if let _ = result, let kmess = (result as? [Message]) {
                    
                    let datesArray = kmess.compactMap { $0.dateShortForm }
                    var dic = [String:[Message]]()
                    datesArray.forEach {
                        let dateKey = $0
                        let filterArray = kmess.filter { $0.dateShortForm == dateKey }
                        dic[$0] = filterArray//.sorted(){$0.timeShortForm < $1.timeShortForm}
                    }
                    let keysArr = dic.keys
                    self.keys =  keysArr.sorted().reversed()
                    self.messages = dic
                    
                    self.tblView.reloadData()
                }
            }
        }
    }

}


extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages[self.keys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 30))
        titleLabel.text = self.messages[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = self.view.tintColor
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! MessageTableViewCell
        
        cell.messageLbl.text = self.messages[self.keys[indexPath.section]]?[indexPath.row].message
        cell.timeStampLbl.text = self.messages[self.keys[indexPath.section]]?[indexPath.row].createdDate?.date?.displayTime
        
        if let urlString = self.messages[self.keys[indexPath.section]]?[indexPath.row].userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.profileImgView.sd_setImage(with:url, completed: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}


