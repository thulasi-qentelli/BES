//
//  LocationsViewController.swift
//  BES
//
//  Created by Thulasi Ram Boddu on 22/08/19.
//  Copyright © 2019 Qentelli. All rights reserved.
//

import UIKit
import MBProgressHUD
import SDWebImage
import CoreLocation
import MapKit

class LocationsViewController: UIViewController {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var profileView: ProfileDisplayView!
    var locations: [Location] = []
    var filteredLocations: [Location] = []
    let cellReuseIdendifier = "LocationTableCell"
    @IBOutlet weak var mapView: MKMapView!
    var markerOrder: MapPlaceMark!
    var filteredRegions:[String] = []
    var filteredServices:[String] = []
    var filteredBasins : [String] = []
    var isFilterPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        profileView.user = AppController.shared.user
        self.mapView.isHidden = true
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        self.navigationItem.titleView = imageView
        
        let menubutton = UIButton(type: .custom)
        menubutton.setImage(UIImage(named: "menu"), for: .normal)
        menubutton.addTarget(self, action: #selector(menuBtnAction), for: .touchUpInside)
        
        let barButton1 = UIBarButtonItem(customView: menubutton)
        
        let currWidth1 = barButton1.customView?.widthAnchor.constraint(equalToConstant: 28)
        currWidth1?.isActive = true
        let currHeight1 = barButton1.customView?.heightAnchor.constraint(equalToConstant: 28)
        currHeight1?.isActive = true
        self.navigationItem.leftBarButtonItem = barButton1
        
        
        let lopgoutbutton = UIButton(type: .custom)
        lopgoutbutton.setImage(UIImage(named: "logout_white_nav"), for: .normal)
        lopgoutbutton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        
        let barButton2 = UIBarButtonItem(customView: lopgoutbutton)
        
        let currWidth2 = barButton2.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth2?.isActive = true
        let currHeight2 = barButton2.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight2?.isActive = true
        self.navigationItem.rightBarButtonItem = barButton2
        
        if isFilterPresented == false {
            
            filteredRegions = []
            filteredBasins = []
            filteredServices = []
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait"
            
            NetworkManager().get(method: .getAllLocations, parameters: [:]) { (result, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    if error != nil {
                        self.view.makeToast(error, duration: 2.0, position: .center)
                        return
                    }
                    
                    if let _ = result, let kmess = (result as? [Location]) {
                        self.locations = kmess
                        self.locations.sort(by: { (loc1, loc2) -> Bool in
                            loc1.getTitle() < loc2.getTitle()
                        })
                        self.filteredLocations = self.locations
                        self.tblView.reloadData()
                        let mapModel = MapViewModel(locations: self.locations, mapView: self.mapView)
                        mapModel.loadDetails()
                        self.setupFiletrs()
                        
                    }
                }
            }
        }
        else {
            isFilterPresented = false
        }
    }
    
    func setupFiletrs() {
        
        
        
    }
    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.loadLoginView()
    }
    
    @IBAction func mapSwitchTapped(_ sender: UIButton) {
        
        isFilterPresented = true
        
        let filterView = FilterViewController()
        filterView.locations = self.locations
        filterView.filteredRegions = self.filteredRegions
        filterView.filteredServices = self.filteredServices
        filterView.filteredBasins = self.filteredBasins
        
        filterView.getFilteredLocations = { (loc,filReg,filSer,filBas) in
            self.filteredLocations = loc
            self.filteredRegions = filReg
            self.filteredServices = filSer
            self.filteredBasins = filBas
            self.tblView.reloadData()
            
            let mapModel = MapViewModel(locations: self.locations, mapView: self.mapView)
            mapModel.loadDetails()
//            self.setupFiletrs()
            
        }
        self.present(filterView, animated: true) {
            self.tblView.setContentOffset(.zero, animated: true)
        }
        
            
            
            
//        self.tblView.isHidden = !self.tblView.isHidden
//        self.mapView.isHidden = !self.mapView.isHidden
//        sender.isSelected = !sender.isSelected
    }
    
    func setupUI() {
        self.tblView.estimatedRowHeight = 60
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.register(UINib.init(nibName: cellReuseIdendifier, bundle: nil), forCellReuseIdentifier: cellReuseIdendifier)
    }
    
}


extension LocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLocations.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        let titleLabel = UILabel(frame: CGRect(x: 30, y: 60, width: UIScreen.main.bounds.size.width - 60, height: 60))
        titleLabel.text = "Locations"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.backgroundColor = UIColor.clear
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdendifier, for: indexPath) as! LocationTableCell
        
        let location = filteredLocations[indexPath.row]
        
        cell.titleLbl.text = location.getTitle()
        cell.addressLbl.text = location.getAddress()
        cell.phoneLbl.text = location.phone
        cell.regionLbl.text = location.region
        cell.servicesLbl.text = location.services
        cell.basinLbl.text = location.basins
        cell.location = location
        
        cell.locationAction = { loc in
            print("Location action")
        }
        cell.phoneAction = { loc in
            print("Phone aciton")
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension LocationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        let mark: MapPlaceMark = annotation as! MapPlaceMark
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        }
        else{
            annotationView?.annotation = annotation
        }
        annotationView?.image = mark.image
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        if view.annotation is MKUserLocation
        {
            return
        }
        let starbucksAnnotation = view.annotation as! MapPlaceMark
        markerOrder = starbucksAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.starbucksName.text = starbucksAnnotation.title
        calloutView.starbucksAddress.text = starbucksAnnotation.address
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
        calloutView.iconbtn.addTarget(self, action: #selector(popup), for: .touchUpInside)
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    
    @objc func popup(){
        //        MTPopUp(frame: (self.view.window?.frame)!).show(complete: { (index) in
        //            if index == 1{
        //                AppController.shared.loadOrderDetails(order: self.markerOrder.serviceOrder)
        //            }else if index == 2{
        //                Directions().navigate_to_map(order: self.markerOrder.serviceOrder)
        //            }
        //
        //        }, view: (self.view.window)!, animationType: MTAnimation.TopToMoveCenter,  btnArray: ["Details","Directions","   "],strTitle: "Navigate To")
    }
    
}


