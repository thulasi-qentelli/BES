//
//  MessagesViewModel.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MessagesViewModel{
    
    let defaults = UserDefaults.standard
    let besService = BESService()
    var didGetMessages : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var messages = [Message]()
    var groupedMessages = [GroupedMessages]()
    
    func getMessages(){
        
        self.messages.removeAll()
        self.groupedMessages.removeAll()
        
        besService.getMessages()
            .done{ messages in
                self.messages = messages
                self.groupMessages()
            }.catch{ error in
                
                if let savedMessages = self.getSavedMessages(){
                    self.groupedMessages = savedMessages
                    self.didGetMessages.accept(true)
                }else{
                    self.didGetMessages.accept(false)
                }
        }
    }
    
    func groupMessages(){
        
        var allDates = [String]()
        
        for message in self.messages{
            if let time = message.createdDate{
                let date = time.components(separatedBy: " ")
                allDates.append(date.first!)
            }
        }
        
        let uniqueDates = Array(Set(allDates))
        
        for eachDate in uniqueDates{
            
            let groupMessages = self.messages.filter{$0.createdDate!.contains(eachDate)}
            let item = GroupedMessages(eachDate, groupMessages)
            self.groupedMessages.append(item)
        }
        
        if self.groupedMessages.count == 0 || self.groupedMessages.count == 1 {
            self.didGetMessages.accept(true)
            return
        }
        
        for i in  0...self.groupedMessages.count-1{
            
            var currentGroup = self.groupedMessages[i]
            let sortedGroup = currentGroup.messges!.sorted(by: { $0.id! > $1.id! })
            
            currentGroup.messges = sortedGroup
            self.groupedMessages.remove(at: i)
            self.groupedMessages.insert(currentGroup, at: i)
        }
        
        let sortedGroups = self.groupedMessages.sorted(by:{ $0.date! > $1.date! })
        self.groupedMessages = sortedGroups
        self.saveMessages()
        
        self.didGetMessages.accept(true)
    }
   
    func saveMessages(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.groupedMessages) {
            defaults.set(encoded, forKey: "SavedMessages")
        }
    }
    
    func getSavedMessages() -> [GroupedMessages]?{
        if let savedMessages = defaults.object(forKey: "SavedMessages") as? Data {
            let decoder = JSONDecoder()
            if let loadedMessages = try? decoder.decode([GroupedMessages].self, from: savedMessages) {
                return loadedMessages
            }
        }
        return nil
    }
}
