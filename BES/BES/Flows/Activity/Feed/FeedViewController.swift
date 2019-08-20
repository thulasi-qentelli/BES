//
//  FeedViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SDWebImage

class FeedViewController: UIViewController {
    
    fileprivate var viewModel : FeedViewModel!
    fileprivate var router    : FeedRouter!
    let disposeBag            = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView : UIView!
    @IBOutlet weak var tblFeed : UITableView!
    @IBOutlet weak var btnProfile : UIButton!
    let feedCellReuseIdentifier = "FeedCellReuseIdentifier"
    let pullToRefresh = UIRefreshControl()
    var expandedRow : Int?
    
    init(with viewModel:FeedViewModel,_ router:FeedRouter){
        
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: "FeedViewController", bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        setUpRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        viewModel.getFeeds()
        if let userImage = appDelegate.user?.pic{
            let urlString = userImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url  = URL(string: urlString!){
                self.btnProfile.imageView!.sd_setImage(with:url){
                    image,error,cache,d in
                    if let unwrappedImage = image{
                        self.btnProfile.setImage(unwrappedImage, for: .normal)
                    }
                }
            }
        }
    }
    

    func setUpViews(){

        self.navigationController?.isNavigationBarHidden = true
        headerView.dropShadow()
        
        if let userImage = appDelegate.user?.pic{
            let urlString = userImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url  = URL(string: urlString!){
                self.btnProfile.imageView!.sd_setImage(with:url){
                    image,error,cache,d in
                    if let unwrappedImage = image{
                        self.btnProfile.setImage(unwrappedImage, for: .normal)
                    }
                }
            }
        }
        
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.clipsToBounds = true
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        
        tblFeed.register(UINib(nibName: "FeedTableCell", bundle: nil), forCellReuseIdentifier: feedCellReuseIdentifier)
        tblFeed.delegate = self
        tblFeed.dataSource = self
//        tblFeed.estimatedRowHeight = 365
//        tblFeed.rowHeight = UITableView.automaticDimension
        tblFeed.tableFooterView = UIView()
        
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        
        pullToRefresh.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tblFeed.addSubview(pullToRefresh)
    }
    
    func setUpRx(){
        
        viewModel.didGetFeeds.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                self.expandedRow = nil
                self.pullToRefresh.endRefreshing()
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.tblFeed.reloadData()
                
            }).disposed(by: disposeBag)
    }
    
    @objc func refresh(){
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        self.viewModel.getFeeds()
    }
    
    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    @objc func likePost(sender:UIButton){
        
        if !Common.hasConnectivity() {
            self.view.makeToast(networkUnavailable, duration: 2.0, position: .center)
            return
        }
        
        var currentFeed = self.viewModel.feedDetails[sender.tag]
        guard let unwrappedUserHasLiked = currentFeed.userHasLiked else {return}
        if unwrappedUserHasLiked{ return }
        
        guard let unwarppedFeedDetails = currentFeed.feed else {return}
        guard let unwarppedLikeCount = unwarppedFeedDetails.likecount else {return}
        
        currentFeed.userHasLiked = true
        currentFeed.feed.likecount = unwarppedLikeCount+1
        
        self.viewModel.feedDetails.remove(at: sender.tag)
        self.viewModel.feedDetails.insert(currentFeed, at: sender.tag)
        self.viewModel.saveLike(for: unwarppedFeedDetails.id!)

        tblFeed.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)

    }
    
    @objc func showComments(sender:UIButton){
        
        let currentFeed = self.viewModel.feedDetails[sender.tag]
        if let comments = currentFeed.comments,let feed = currentFeed.feed{
            self.router.navigateToComments(with: comments,postId: feed.id!)
        }
        
    }
}

extension FeedViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.feedDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.viewModel.feedDetails.count > indexPath.row else {return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: feedCellReuseIdentifier, for: indexPath) as! FeedTableCell
        
        let currentFeed = viewModel.feedDetails[indexPath.row]
//        cell.txtBody.didClickDelegate = self
        cell.txtBody.tag = indexPath.row
        
        if let unwrappedExpandedRow = self.expandedRow{
            if unwrappedExpandedRow == indexPath.row{
                cell.isExpanded = true
            }
        }
        
        let textView = ReadMoreTextView()
        textView.text = currentFeed.feed!.content
        
        let size = CGSize(width:self.view.frame.width-116 , height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
       
        cell.configure(with: currentFeed,textViewHeight: estimatedSize.height)
        
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(likePost(sender:)), for: .touchUpInside)
        
        cell.btnComment.tag = indexPath.row
        cell.btnComment.addTarget(self, action: #selector(showComments(sender:)), for: .touchUpInside)
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        guard tableView == tblFeed else { return 0.0 }
        guard self.viewModel.feedDetails.count > indexPath.row else {return 0.0}
        
        let currentFeed = self.viewModel.feedDetails[indexPath.row]
        var height : CGFloat = 0.0
        
        if let image = currentFeed.feed!.image{
            height = image.isEmpty ? 224 : 355.0
        }else{
            height = 224.0
        }
        
        guard let unwrappedExpandedRow = self.expandedRow else {return height}
        guard unwrappedExpandedRow == indexPath.row else {return height}
        
        let textView = ReadMoreTextView()
        textView.text = currentFeed.feed!.content
        
        let size = CGSize(width:self.view.frame.width-116 , height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        height = height-80+estimatedSize.height+20
        
        return height
    }
    
}

/*
extension FeedViewController : ReadMoreTextViewDelegate {
    
    func didClickSeeMore(for row:Int) {
 
        self.expandedRow = row
        
        var reloadingCells = [IndexPath(row: row, section: 0)]
        if row != 0{
            reloadingCells.append(IndexPath(row: row-1, section: 0))
        }
        if row != self.viewModel.feedDetails.count-1{
            reloadingCells.append(IndexPath(row: row+1, section: 0))
        }
        
        DispatchQueue.main.async {
            self.tblFeed.reloadRows(at:reloadingCells, with: .fade)
        }
    }
}
 */

