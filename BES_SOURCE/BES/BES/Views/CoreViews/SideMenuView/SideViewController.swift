//
//  SideViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import SDWebImage


class SideViewController: UIViewController {

    @IBOutlet weak var profileView: SideProfileView!
    @IBOutlet weak var home: SideMenuCell!
    @IBOutlet weak var locations: SideMenuCell!
    @IBOutlet weak var messages: SideMenuCell!
    @IBOutlet weak var feedback: SideMenuCell!
    @IBOutlet weak var inquiry: SideMenuCell!
    @IBOutlet weak var invoices: SideMenuCell!
    @IBOutlet weak var documents: SideMenuCell!
    
    @IBOutlet weak var logout: SideMenuCell!
    
    var menuTapped:(Int)->Void = { index in
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      
        
      
        profileView.user = AppController.shared.user
        profileView.editTapped = {
            let profileVC = ProfileViewController()
            let nav = UINavigationController(rootViewController: profileVC)
            self.present(nav, animated: true, completion: nil)
            self.sideMenuViewController?.hideMenuViewController()
            
        }
        
        home.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(0)
        }
        locations.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(1)
        }
        messages.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(2)
        }
        feedback.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(3)
        }
        inquiry.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(4)
        }
        invoices.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(5)
        }
        documents.btnClickAction = {
            self.sideMenuViewController?.hideMenuViewController()
            self.menuTapped(6)
        }
        logout.btnClickAction = {
//            self.dismiss(animated: true, completion: nil)
            self.menuTapped(7)
        }
        
        
        var parameters = ParameterDetail()
        parameters.userId = "\(AppController.shared.user!.id!)"
        
        if let parm = parameters.dictionary {
            
            NetworkManager().get(method: .getUser, parameters: parm) { (result, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    AppController.shared.user = result as? User
                    saveUserDetails(user: result as! User)
                    self.profileView.user = AppController.shared.user
                }
            }
            
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

