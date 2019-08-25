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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 20, width: UIScreen.main.bounds.size.width - 60, height: 60))
        titleLabel.text = "Messages"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.backgroundColor = UIColor.clear
        view.addSubview(titleLabel)
        self.tblView.tableHeaderView = view
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.navigationItem.titleView = imageView
        
        let menubutton = UIButton(type: .custom)
        menubutton.setImage(UIImage(named: "menu"), for: .normal)
        menubutton.addTarget(self, action: #selector(menuBtnAction), for: .touchUpInside)
        
        let barButton1 = UIBarButtonItem(customView: menubutton)
        
        let currWidth1 = barButton1.customView?.widthAnchor.constraint(equalToConstant: 28)
        currWidth1?.isActive = true
        let currHeight1 = barButton1.customView?.heightAnchor.constraint(equalToConstant: 28)
        currHeight1?.isActive = true
        self.navigationItem.leftBarButtonItem = barButton1
        
        
        let lopgoutbutton = UIButton(type: .custom)
        lopgoutbutton.setImage(UIImage(named: "logout_white_nav"), for: .normal)
        lopgoutbutton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: lopgoutbutton)
        
        let currWidth2 = barButton2.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth2?.isActive = true
        let currHeight2 = barButton2.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight2?.isActive = true
        self.navigationItem.rightBarButtonItem = barButton2
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Please wait"
        
        NetworkManager().get(method: .getMessagesByEmail, parameters: ["email" : AppController.shared.user?.email ?? ""]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
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
    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.loadLoginView()
    }


    func setupUI() {
        self.tblView.estimatedRowHeight = 60
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.register(UINib.init(nibName: cellReuseIdendifier, bundle: nil), forCellReuseIdentifier: cellReuseIdendifier)
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
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 40))
        titleLabel.text = self.messages[self.keys[section]]?.first?.dateShortForm
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.blue
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! MessageTableViewCell
        
        cell.messageLbl.text = self.messages[self.keys[indexPath.section]]?[indexPath.row].message
        cell.timeStampLbl.text = self.messages[self.keys[indexPath.section]]?[indexPath.row].createdDate?.components(separatedBy: " ").last
        
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


