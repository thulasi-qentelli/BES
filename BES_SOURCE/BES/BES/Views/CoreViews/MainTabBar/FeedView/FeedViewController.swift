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
    var feedViewModels:[FeedViewModel] = [FeedViewModel]()
    let feedCellReuseIdentifier = "FeedTableViewCell"
    let refreshControl = UIRefreshControl()
   var cellHeights: [IndexPath : CGFloat] = [:]
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
//        self.tblView.estimatedRowHeight = 260
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
                    self.feedViewModels.removeAll()
                    self.feeds = kmess.sorted(by: { $0.createdDateObj!.compare($1.createdDateObj!) == .orderedDescending })
                     self.feeds.forEach({ (feed) in
                        self.feedViewModels.append(FeedViewModel(feed: feed))
                    })
                    self.tblView.reloadData()
                     self.noDataLbl.isHidden = true
                }
                else {
                    self.feeds = []
                    self.feedViewModels.removeAll()
                    self.tblView.reloadData()
                    self.noDataLbl.isHidden = false
                }
            }
        }
    }
    
}


extension FeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedViewModels.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.feedViewModels[indexPath.row]
        return model.isTextExpanded ? model.getExpandedHeight() : model.getNormaHeight()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: feedCellReuseIdentifier, for: indexPath) as! FeedTableViewCell
        
        let viewModel = feedViewModels[indexPath.row]
        
        viewModel.imageUpdated = {
            cell.setupUI()
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        }
        var feed = viewModel.feed
        
        cell.setupCell(viewModel: viewModel)
        cell.indexPAth = indexPath
        cell.updateUI = { idxPath in
            tableView.beginUpdates()
            //Not needed to reload
//            tableView.reloadRows(at: [idxPath], with: .automatic)
            tableView.endUpdates()
        }
        
        
        cell.likedLbl.text = "0 Likes"
        cell.commentsLbl.text = "0 Comments"
        
        cell.likedLbl.text = "\(feed.getLikesCount()) Likes"
        
        if let comments = feed.comments {
            cell.commentsLbl.text = "\(comments.count) Comments"
        }
    
        cell.thumUpImgView.image = UIImage(named: "thumb_up")
        
        if let likedObj = feed.likeObj, let count = likedObj.likes, count > 0{
            cell.thumUpImgView.image = UIImage(named: "thumb_up_orange")
        }
        
        //Profile Image
        
        cell.profileImgPlaceholderView.isHidden = false
        
       
        
//        return cell
        
        
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

