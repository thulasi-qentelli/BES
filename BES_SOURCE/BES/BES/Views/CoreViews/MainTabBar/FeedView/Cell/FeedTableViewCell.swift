//
//  FeedTableViewCell.swift
//  Layout
//
//  Created by Thulasi Ram Boddu on 25/08/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import SDWebImage

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
        
        self.imgView.image = nil
        self.profileImgView.image = nil
        
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
        
        self.profileImgPlaceholderView.isHidden = true

        self.profileImgView.setGmailTypeImageFromString(str: self.feedModel?.feed.userName?.gmailString ?? " ", bgcolor: UIColor.black)

        let placeHolderImg = getGmailTypeImageFromString(str: self.feedModel?.feed.userName?.gmailString ?? " ", bgcolor: UIColor.black)
        
        if let urlString = self.feedModel?.feed.userPic?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                self.profileImgView.sd_setImage(with: url) { (image, error, cache, url) in
                    self.profileImgView.sd_setImage(with: url, placeholderImage: placeHolderImg , options:SDWebImageOptions.avoidAutoSetImage, completed: { (image, error, cacheType, url) in
                        DispatchQueue.main.async {
                            if let image = image, let userPic = self.feed?.userPic, userPic == url!.absoluteString {
                                self.profileImgView.image = image
                            }
                        }
                    })
                }
            }
        }
        self.imgHeight.constant = self.feedModel!.feedImgHeight
        self.imgView.backgroundColor  = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        if let urlString = self.feedModel?.feed.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)  {
            if let url  = URL(string: urlString){
                self.profileImgView.sd_setImage(with: url, placeholderImage: nil , options:SDWebImageOptions.avoidAutoSetImage, completed: { (image, error, cacheType, url) in
                    DispatchQueue.main.async {
                        if let image = image, let pic = self.feed?.image, pic == url!.absoluteString {
                            self.imgView.image = image
                        }
                    }
                })
            }
        }
    }
}

