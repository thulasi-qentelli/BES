//
//  FilterViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 01/08/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate{
    func didSelectOption(_ option:String)
}

 class FilterViewController: UIViewController {
    
    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return bdView
    }()
    
    let menuView = UITableView()
    let menuHeight = UIScreen.main.bounds.height / 2
    var isPresenting = false
    var options = [String]()
    let filterCellReuseIdentifier = "FilterCellReuseIdentifier"
    let headerCellReuseIdentifier = "HeaderCellReuseIdentifier"
    var selectedRow : Int?
    var delegate : FilterViewControllerDelegate?
    var selectedFilter : String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(menuView)
        
        menuView.backgroundColor = UIColor.white
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.heightAnchor.constraint(equalToConstant: menuHeight).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        menuView.register(UINib(nibName: "FilterTableViewCell", bundle: nil), forCellReuseIdentifier: filterCellReuseIdentifier)
         menuView.register(UINib(nibName: "HeaderTableViewCell", bundle: nil), forCellReuseIdentifier: headerCellReuseIdentifier)

        menuView.delegate = self
        menuView.dataSource = self
        menuView.tableFooterView = UIView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FilterViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension FilterViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            menuView.frame.origin.y += menuHeight
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y -= self.menuHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.menuView.frame.origin.y += self.menuHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

extension FilterViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return options.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: headerCellReuseIdentifier, for: indexPath) as! HeaderTableViewCell
            
            cell.btnCancel.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            cell.btnDone.addTarget(self, action: #selector(done), for: .touchUpInside)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: filterCellReuseIdentifier, for: indexPath) as! FilterTableViewCell
        
        let currentOption = self.options[indexPath.row-1]
        var isSelected = false
        if let unwrappedSelectedRow = self.selectedRow{
            if unwrappedSelectedRow == indexPath.row{
                isSelected = true
            }
        }
        
        cell.configureWith(currentOption,isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row != 0 else {return}
        guard self.selectedRow != indexPath.row else{return}
        
        self.selectedRow = indexPath.row
        self.menuView.reloadData()
    }
    
    @objc func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func done(){
        
        if let unwrappedSelectedRow = self.selectedRow{
            let selectedOption = self.options[unwrappedSelectedRow-1]
            self.delegate?.didSelectOption(selectedOption)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
