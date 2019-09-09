//
//  InvoiceViewController.swift
//  BES
//
//  Created by YPO  on 19/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

class InvoiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
    }

}
