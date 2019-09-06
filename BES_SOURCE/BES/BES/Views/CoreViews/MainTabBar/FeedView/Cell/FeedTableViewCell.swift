//
//  FeedTableViewCell.swift
//  Layout
//
//  Created by Thulasi Ram Boddu on 25/08/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    var feed: Feed?
    var feedModel:FeedViewModel?
    var indexPAth: IndexPath?
    @IBOutlet weak var displayTextLbl: UILabel!
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileImgPlaceholderView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    @IBOutlet weak var likedLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var thumUpImgView: UIImageView!
    @IBOutlet weak var commentsImgView: UIImageView!
    
    var updateUI:(IndexPath)->Void = {  indexpath in
    
    }
    var imageViewTapAction:(UIImageView)->Void = { sender in
        
    }
    
    var likeBtnTap:(Feed)->Void = { feed in
        
    }
    var commentBtnTap:(Feed)->Void = { feed in
        
    }
    
    var string = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImgView.layer.cornerRadius = 25
        profileImgView.layer.masksToBounds = true
        self.imgView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        self.imgView.addGestureRecognizer(tapGesture)
    }

   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func readMoreAction(_ sender: UIButton) {
        self.feedModel?.readMoreAction()
        self.setupUI()
        self.updateUI(self.indexPAth!)
    }
    
    @IBAction func likeBtnAction(_ sender: UIButton) {
        if let kFeed = self.feed {
            likeBtnTap(kFeed)
        }
    }
    
    @IBAction func commentBtnAction(_ sender: UIButton) {
        if let kFeed = self.feed {
            commentBtnTap(kFeed)
        }
    }
    
    @objc func imageViewTapped() {
        imageViewTapAction(self.imgView)
    }

    
    func setupCell(viewModel:FeedViewModel) {
        self.feed = viewModel.feed
        self.feedModel = viewModel
        setupUI()
    }
    
    func setupUI() {
        self.nameLbl.text = self.feedModel!.feed.userName ?? ""
        self.timestampLbl.text = self.feedModel!.dateForDisplay
        
        self.readMoreBtn.isHidden = !self.feedModel!.isReadMoreRequired
        self.readMoreBtn.isSelected = self.feedModel!.isTextExpanded
        self.txtLbl.text = self.feedModel!.getTextLabelContent()
        self.displayTextLbl.text = self.feedModel!.getDisplayTextLabelContet()
        
        self.txtLbl.isHidden = self.feedModel!.isTextExpanded
        self.displayTextLbl.isHidden = !self.feedModel!.isTextExpanded
        
        
        self.likedLbl.text = "0 Likes"
        self.commentsLbl.text = "0 Comments"
        
        self.likedLbl.text = "\(self.feedModel!.feed.getLikesCount()) Likes"
        
        
        self.commentsImgView.image = UIImage(named: "question_answer_black")
        
        if let comments = self.feedModel!.feed.comments, comments.count > 0 {
            self.commentsImgView.image = UIImage(named: "question_answer")
            self.commentsLbl.text = "\(comments.count) Comments"
        }
        
        self.thumUpImgView.image = UIImage(named: "thumb_up_black")
        
        if let likedObj = self.feedModel!.feed.likeObj, let count = likedObj.likes, count > 0{
            self.thumUpImgView.image = UIImage(named: "thumb_up")
        }
        
        
        
        self.profileImgPlaceholderView.isHidden = false
//        if self.feedModel!.profileImg != nil {
//            self.profileImgView.image = self.feedModel!.profileImg
//            self.profileImgPlaceholderView.isHidden = true
//        }
//        else {
//            self.feedModel!.downloadProfileImg()
//        }
        
        if let urlString = self.feedModel?.feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                self.profileImgView.sd_setImage(with: url) { (image, error, cache, url) in
                    if let img = image {
                        self.profileImgPlaceholderView.isHidden = true
                    }
                }
            }
        }
        self.imgHeight.constant = self.feedModel!.feedImgHeight
        if self.feedModel!.feedImg != nil {
            self.imgView.image = self.feedModel!.feedImg
        }
        else {
            self.feedModel!.downloadFeedImg()
        }
        
    }
}

