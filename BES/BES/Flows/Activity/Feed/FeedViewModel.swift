//
//  FeedViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct ActivityFeed : Codable{
    var feed : Feed!
    var userHasLiked:Bool!
    var comments:[Comment]!
    
    init(feed:Feed,userHasLiked:Bool,comments:[Comment]){
        self.feed = feed
        self.userHasLiked = userHasLiked
        self.comments = comments
    }
}

class FeedViewModel{
    
    let defaults = UserDefaults.standard
    let besService = BESService()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var didGetFeeds : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var feeds = [Feed]()
    var feedDetails = [ActivityFeed]()
    
    func getFeeds(){
        
        self.feeds.removeAll()
        self.feedDetails.removeAll()
        
        besService.getFeeds()
            .done{ feeds in
                self.feeds = feeds
                self.populateFeeds()
            }.catch{ error in
                print(error)
                if let savedFeeds = self.getSavedFeeds(){
                    self.feedDetails = savedFeeds
                    self.didGetFeeds.accept(true)
                }else{
                    self.didGetFeeds.accept(false)
                }
        }
    }
    
    func populateFeeds(){
        
        guard let user = appDelegate.user else {return}
        
        for eachFeed in feeds{
            
            let feedDetails = eachFeed
            var userHasLiked = false
            var commentsDetails = [Comment]()
            
            if let comments = eachFeed.comments{
                commentsDetails = comments
            }
            
            if let unwrappedLikes = eachFeed.likes{
                for eachLike in unwrappedLikes{
                    if let unwrappedLike = eachLike.likes{
                        if unwrappedLike == 1{
                            if let unwrappedEmail = eachLike.email{
                                if unwrappedEmail == user.email!{
                                    userHasLiked = true
                                }
                            }
                        }
                    }
                }
            }
            
            let activityFeed = ActivityFeed(feed: feedDetails, userHasLiked: userHasLiked, comments: commentsDetails)
            self.feedDetails.append(activityFeed)
        }
       
        self.saveFeeds()
        self.didGetFeeds.accept(true)
    }
    
    
    func saveLike(for postId:Int){
        besService.saveLike(postId: postId)
            .done{ success in
               print(success)
            }.catch{ error in
                print(error)
        }
    }
    
    func getSavedFeeds() -> [ActivityFeed]?{
        
        if let savedFeeds = defaults.object(forKey: "SavedFeeds") as? Data {
            let decoder = JSONDecoder()
            if let feeds = try? decoder.decode([ActivityFeed].self, from: savedFeeds) {
                return feeds
            }
        }
        return nil
    }
    
    func saveFeeds(){
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.feedDetails) {
            defaults.set(encoded, forKey: "SavedFeeds")
        }
    }
}

