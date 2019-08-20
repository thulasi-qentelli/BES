//
//  MessagesViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MessagesViewController: UIViewController {
    
    fileprivate var viewModel : MessagesViewModel!
    fileprivate var router    : MessagesRouter!
    let disposeBag            = DisposeBag()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerView : UIView!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var tblMessages : UITableView!
    @IBOutlet weak var btnProfile : UIButton!
    let messageCellReuseIdentifier = "MessageCellReuseIdentifier"
    var pullToRefesh = UIRefreshControl()
    
    init(with viewModel:MessagesViewModel,_ router:MessagesRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "MessagesViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        headerView.dropShadow()
        
        tblMessages.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: messageCellReuseIdentifier)
        tblMessages.delegate = self
        tblMessages.dataSource = self
        tblMessages.estimatedRowHeight = UITableView.automaticDimension
        tblMessages.tableFooterView = UIView()
        
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
        
        pullToRefesh.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tblMessages.addSubview(pullToRefesh)
        
        setUpRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getMessages()
    }
    
    func setUpRx(){
        
        viewModel.didGetMessages.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                self.pullToRefesh.endRefreshing()
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.lblTitle.text = "Messages(\(self.viewModel.messages.count))"
                self.tblMessages.reloadData()
                
        }).disposed(by: disposeBag)
    }
    
    @objc func refresh(){
        
        self.viewModel.getMessages()
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


}

extension MessagesViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return viewModel.groupedMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let currentGroup = viewModel.groupedMessages[section]
        return currentGroup.messges!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.viewModel.groupedMessages.count > indexPath.row else {return UITableViewCell()}
        
        let cell = tableView.dequeueReusableCell(withIdentifier: messageCellReuseIdentifier, for: indexPath) as! MessageTableViewCell
        
        let currentGroup  = viewModel.groupedMessages[indexPath.section]
        let currentMessage = currentGroup.messges![indexPath.row]
        cell.configureWith(currentMessage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMessages.frame.width, height: 60))
        
        let currentGroup  = viewModel.groupedMessages[section]
        if let date = getDateString(from: currentGroup.date!){
            view.text = date
        }else{ view.text = "" }
        view.textAlignment = .center
        view.font = UIFont(name: "Montserrat-Regular", size: 12)!
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 60.0
    }
    
    func getDateString(from inputString:String) -> String? {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from:inputString) {
            return (dateFormatterPrint.string(from: date))
        } else {
            return nil
        }
    }
}

extension UIView {
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 5
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}
