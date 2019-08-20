//
//  VerificationViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 26/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class VerificationViewController: UIViewController {
    
    fileprivate var viewModel : VerificationViewModel!
    fileprivate var router    : VerificationRouter!
    
    @IBOutlet weak var btnSignIn : UIButton!
    
    init(with viewModel:VerificationViewModel,_ router:VerificationRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "VerificationViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    func setupViews(){
        
        btnSignIn.layer.cornerRadius = 4
        btnSignIn.clipsToBounds = true
        
        btnSignIn.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }

    @objc func signIn(){
        
        self.router.navigateToSignIn()
    }

}
