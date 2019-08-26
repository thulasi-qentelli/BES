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
        
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
        
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
        
        cell.timestampLbl.text = feed.createdDate?.date?.humanDisplayDaateFormat()
        cell.displayTextLbl.text = ""
        cell.getTextForReadmore(kStr: feed.content ?? "", numberOfLines: 3)
        cell.txtLbl.isHidden = false
        cell.readMoreBtn.isSelected = false
        cell.profileImgPlaceholderView.isHidden = false
        cell.nameLbl.text = feed.userName
        if let urlString = feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.profileImgView.sd_setImage(with:url, completed: nil)
                cell.profileImgPlaceholderView.isHidden = true
            }
        }
        cell.imgHeight.constant = 0
        if let urlString = feed.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                cell.imgView?.sd_setImage(with: url, completed: { (image, error, type, url) in
                    cell.imgHeight.constant = image?.heightForWidth(width: UIScreen.main.bounds.size.width - 60) ?? 0
                    tableView.beginUpdates()
                    tableView.endUpdates()
                })
            }
        }
        
        
        cell.readMoreFunction = { (sender, str) in
            if sender.isSelected == true {
                cell.displayTextLbl.text = ""
                cell.getTextForReadmore(kStr: str, numberOfLines: 3)
                cell.txtLbl.isHidden = false
            } else {
                cell.displayTextLbl.text = str
                cell.txtLbl.text =  str + "  Read More"
                cell.txtLbl.isHidden = true
            }
            sender.isSelected = !sender.isSelected
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
}

extension UIImage {
    func heightForWidth(width:CGFloat) -> CGFloat{
    
        return (width/self.size.width)*self.size.height
    }
}

