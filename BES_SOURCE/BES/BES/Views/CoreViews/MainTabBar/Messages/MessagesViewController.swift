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
    let cellReuseIdendifier = "MessageTableViewCell1"
    var keys:[String] = []
    let refreshControl = UIRefreshControl()
    var colorsDict:[String:UIColor] = [:]

    @IBOutlet weak var headerView: TableSectionHeaderView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        self.loadMessages(showLoader: true)
        self.headerView.title = "Messages"
        
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
            self.noDataLbl.isHidden = true
        }
        
        NetworkManager().get(method: .getMessagesByEmail, parameters: ["email" : AppController.shared.user?.email ?? ""]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.refreshControl.endRefreshing()
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    
                    if self.messages.count == 0{
                        self.noDataLbl.isHidden = false
                    }
                    else {
                        self.noDataLbl.isHidden = true
                    }
                    return
                }
                
                if let _ = result, let kmess = (result as? [Message]),kmess.count > 0 {
                    
                    let datesArray = kmess.compactMap { $0.dateShortForm }
                    var dic = [String:[Message]]()
                    datesArray.forEach {
                        let dateKey = $0
                        var filterArray = kmess.filter { $0.dateShortForm == dateKey }
                        
                        filterArray = filterArray.reversed()
                        var isNewName = true
                        var name = ""
                        for i in 0..<filterArray.count {
                            
                            let messs = filterArray[i]
                            if isNewName == true {
                                name = messs.userName!
                                isNewName = false
                                messs.isNameRequired = true
                            }
                            
                            if name != messs.userName! {
                                name = messs.userName!
                                messs.isNameRequired = true
                            }
                        }
                        dic[$0] = filterArray
                    }
                    let keysArr = dic.keys
                    self.keys =  keysArr.sorted().reversed()
                    self.messages = dic
                    self.tblView.reloadData()
                }
                else {
                    self.keys = []
                    self.messages = [:]
                    self.tblView.reloadData()
                    self.noDataLbl.isHidden = false
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
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: UIScreen.main.bounds.size.width - 60, height: 30))
        titleLabel.text = self.messages[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate
        titleLabel.backgroundColor = UIColor(red: 222.0/255.0, green: 242.0/255.0, blue: 249.0/255.0, alpha: 1)
        
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        let width = (self.messages[self.keys[section]]?.first?.createdDate?.date?.messageHeaderDate.widthOfString(usingFont: titleLabel.font) ?? 0) + 20
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! MessageTableViewCell1
        
        if let message = self.messages[self.keys[indexPath.section]]?[indexPath.row] {
            
            cell.nameLbl.text = ""
            if message.isNameRequired {
                cell.nameLbl.text = message.userName?.capitalized
                if colorsDict[message.userName!] == nil {
                    colorsDict[message.userName!] = UIColor.random
                }
                cell.nameLbl.textColor = colorsDict[message.userName!]
            }
  
             cell.profileImgView.setGmailTypeImageFromString(str: message.userName?.gmailString ?? " ", bgcolor: colorsDict[message.userName!] ?? UIColor.black)
            cell.messageLbl.text = (message.message ?? "")
            cell.timeStampLbl.text = message.createdDate?.date?.displayTime
//            cell.profileImgView.image = UIImage(named: "Group")
            
            if let urlString = message.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                if let url  = URL(string: urlString){
                    cell.profileImgView.sd_setImage(with:url, completed: nil)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0).darker() ?? UIColor.darkGray
    }
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}


extension UIImageView {
    func setGmailTypeImageFromString(str:String, bgcolor:UIColor) {
        let lblNameInitialize = UILabel()
        lblNameInitialize.frame.size = CGSize(width: 60.0, height: 60.0)
        lblNameInitialize.textColor = UIColor.white
        lblNameInitialize.text = str.uppercased()
        lblNameInitialize.textAlignment = NSTextAlignment.center
        lblNameInitialize.backgroundColor = bgcolor
        lblNameInitialize.layer.cornerRadius = 30.0
        lblNameInitialize.font = UIFont.systemFont(ofSize: 21)
        
        UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
        lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}


extension String {
    
    var gmailString:String {
        if self.components(separatedBy: " ").count >= 2 {
            let stringNeed = (self.components(separatedBy: " ").map({ $0.first }).compactMap({$0}).reduce("", { String($0) + String($1) }) as NSString).substring(to: 2)
            return stringNeed
        }
        return ""
    }
}
