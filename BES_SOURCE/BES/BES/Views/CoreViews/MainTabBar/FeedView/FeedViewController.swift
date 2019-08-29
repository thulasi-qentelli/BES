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
import SimpleImageViewer

class FeedViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    var feeds: [Feed] = []
    let feedCellReuseIdentifier = "FeedTableViewCell"
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var noDataLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        loadFeeds(showLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
    }
    
    
    func setupUI() {
        self.tblView.estimatedRowHeight = 260
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.register(UINib.init(nibName: feedCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: feedCellReuseIdentifier)
        
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
        loadFeeds(showLoader: true)
    }
    
    func loadFeeds(showLoader:Bool) {
        if showLoader {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
            self.noDataLbl.isHidden = true
        }
        
        NetworkManager().get(method: .getAllFeeds, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.refreshControl.endRefreshing()
                if error != nil {
                    self.view.makeToast(error, duration: 2.0, position: .center)
                    if self.feeds.count == 0{
                        self.noDataLbl.isHidden = false
                    }
                    else {
                        self.noDataLbl.isHidden = true
                    }
                    return
                }
                
                if let _ = result, let kmess = (result as? [Feed]), kmess.count > 0 {
                    self.feeds = kmess.sorted(by: { $0.createdDateObj!.compare($1.createdDateObj!) == .orderedDescending })
                    self.tblView.reloadData()
                     self.noDataLbl.isHidden = true
                }
                else {
                    self.feeds = []
                    self.tblView.reloadData()
                    self.noDataLbl.isHidden = false
                }
            }
        }
    }
    
}


extension FeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = TableSectionHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 90))
        view.titleLbl.text = "Posts"
        view.filterView.isHidden    =   true
        view.backgroundColor = self.view.backgroundColor
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: feedCellReuseIdentifier, for: indexPath) as! FeedTableViewCell
        var feed = feeds[indexPath.row]
        cell.feed = feed
        cell.timestampLbl.text = feed.createdDate?.date?.humanDisplayDaateFormat()
        cell.likedLbl.text = "0 Likes"
        cell.commentsLbl.text = "0 Comments"
        
        cell.likedLbl.text = "\(feed.getLikesCount()) Likes"
        
        if let comments = feed.comments {
            cell.commentsLbl.text = "\(comments.count) Comments"
        }
        
        cell.displayTextLbl.text = ""
        cell.getTextForReadmore(kStr: feed.content ?? "", numberOfLines: 3)
        cell.txtLbl.isHidden = false
        cell.readMoreBtn.isSelected = false
        cell.profileImgPlaceholderView.isHidden = false
        cell.nameLbl.text = feed.userName
    
        cell.thumUpImgView.image = UIImage(named: "thumb_up")
        
        if let likedObj = feed.likeObj, let count = likedObj.likes, count > 0{
            cell.thumUpImgView.image = UIImage(named: "thumb_up_orange")
        }
        
        //Profile Image        
        if let kLocalImg = AppController.shared.imageCache.object(forKey: feed.userPic as NSString? ?? "" as NSString) {
             cell.profileImgView.image = kLocalImg
        }
        else {
            DispatchQueue.global(qos: .background).async {
                if let urlString = feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                    if let url  = URL(string: urlString){
                        cell.profileImgView.sd_setImage(with: url, completed: { (image, error, type, kURL) in
                            DispatchQueue.main.async {
                                if let kImg = image {
                                    AppController.shared.imageCache.setObject(kImg, forKey: feed.userPic! as NSString)
                                    cell.profileImgPlaceholderView.isHidden = true
                                }
                            }
                        })
                    }
                }
            }
        }
        
        if let kLocalImg = AppController.shared.imageCache.object(forKey: feed.image as NSString? ?? "" as NSString) {
            cell.imgView.image = kLocalImg
            cell.imgHeight.constant = kLocalImg.heightForWidth(width: UIScreen.main.bounds.size.width - 60) ?? 0
            tableView.beginUpdates()
            tableView.endUpdates()
            
//            tableView.reloadData()
        }
        else {
            cell.imgHeight.constant = 0
         DispatchQueue.global(qos: .background).async {
            if let urlString = feed.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
                if let url  = URL(string: indexPath.row == 0 ? "https://upload.wikimedia.org/wikipedia/commons/d/d7/Astro_4D_stars_proper_radial_g_b_8mag_big.png" : urlString){
                    cell.imgView?.sd_setImage(with: url, completed: { (image, error, type, url) in
                        
                        DispatchQueue.main.async {
                            if let kImg = image {
                                AppController.shared.imageCache.setObject(kImg, forKey: feed.image! as NSString)
                            cell.imgHeight.constant = image?.heightForWidth(width: UIScreen.main.bounds.size.width - 60) ?? 0
                            tableView.beginUpdates()
                            tableView.endUpdates()
//                                tableView.reloadData()
                            }
                        }
                        
                    })
                }
            }
        }
        
        }
        //Read More Text
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
        
        cell.imageViewTapAction = { sender in
            let configuration = ImageViewerConfiguration { config in
                config.imageView = sender
            }
            self.present(ImageViewerController(configuration: configuration), animated: true)
        }
        
        cell.likeBtnTap = { kFeed in
            feed.likeAction(completion: { (status,error) in
                
                cell.likedLbl.text = "\(feed.getLikesCount()) Likes"
                if status == true {
                    cell.thumUpImgView.image = UIImage(named: "thumb_up_orange")
                }
                else {
                    if error != nil, error! == networkUnavailable {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                    }
                    cell.thumUpImgView.image = UIImage(named: "thumb_up")
                }
                
            })
        }
        cell.commentBtnTap = { kFeed in
            
            if let comments = feed.comments {
                let commentsVC = CommentsViewController()
                commentsVC.commentsSource = comments
                commentsVC.feed = feed
                commentsVC.commentesAdded = { kFeed in
                    feed = kFeed
                    self.tblView.reloadData()
                }
                let navSeven = UINavigationController(rootViewController: commentsVC)
                self.present(navSeven, animated: true, completion: nil)
                
            }
        }
        return cell
    }
}

extension UIImage {
    func heightForWidth(width:CGFloat) -> CGFloat{
    
        return (width/self.size.width)*self.size.height
    }
}

