//
//  CommunicationsViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class CommunicationsViewController: UIViewController {
    
    fileprivate var viewModel : CommunicationsViewModel!
    fileprivate var router    : CommunicationsRouter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnFeedback: UIButton!
    @IBOutlet weak var btnEnquiry: UIButton!
    
    init(with viewModel:CommunicationsViewModel,_ router:CommunicationsRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "CommunicationsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }

    func setUpViews(){
        
        headerView.dropShadow()
        
        btnFeedback.layer.cornerRadius = 4
        btnFeedback.layer.borderWidth = 1
        btnFeedback.layer.borderColor = UIColor(red:0.18, green:0.21, blue:0.31, alpha:1).cgColor
        
        btnEnquiry.layer.cornerRadius = 4
        btnEnquiry.layer.borderWidth = 1
        btnEnquiry.layer.borderColor = UIColor(red:0.18, green:0.21, blue:0.31, alpha:1).cgColor
        
        btnEnquiry.addTarget(self, action: #selector(enquiry), for: .touchUpInside)
        btnFeedback.addTarget(self, action: #selector(feeback), for: .touchUpInside)
        
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
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
    }

    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
   
    @objc func enquiry(){
        
        self.router.navigateToEnquiry()
    }
    
    @objc func feeback(){
        
        self.router.navigateToFeedback()
    }

}
