//
//  FeedViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage

class FeedViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var feeds: [Feed] = []
    let feedCellReuseIdentifier = "FeedTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
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
        
        NetworkManager().get(method: .getAllFeeds, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    return
                }
                
                if let _ = result, let kmess = (result as? [Feed]) {
                    self.feeds = kmess
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
        self.tblView.estimatedRowHeight = 260
        self.tblView.rowHeight = UITableView.automaticDimension
    
        self.tblView.register(UINib.init(nibName: feedCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: feedCellReuseIdentifier)
    }
    
}


extension FeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 20, width: UIScreen.main.bounds.size.width - 60, height: 60))
        titleLabel.text = "Posts"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.backgroundColor = UIColor.clear
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: feedCellReuseIdentifier, for: indexPath) as! FeedTableViewCell
        let feed = feeds[indexPath.row]
        cell.getTextForReadmore(kStr: feed.content ?? "", numberOfLines: 3)
        cell.readMoreBtn.isSelected = false
        cell.profileImgPlaceholderView.isHidden = false
        cell.nameLbl.text = feed.userName
        if let urlString = feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.profileImgView.sd_setImage(with:url, completed: nil)
                cell.profileImgPlaceholderView.isHidden = true
            }
        }
        
        if let urlString = feed.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.imgView?.sd_setImage(with:url, completed: nil)
                cell.imgHeight.constant = 100
            }
            else {
                cell.imgHeight.constant = 0
            }
        }
        else {
             cell.imgHeight.constant = 0
        }
    
        cell.readMoreFunction = { (sender, str) in
            if sender.isSelected == true {
                cell.getTextForReadmore(kStr: str, numberOfLines: 3)
            } else {
                cell.txtLbl.text = str + "                               "
            }
            sender.isSelected = !sender.isSelected
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
}


