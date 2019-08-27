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
    var locations: [Location] = []
    var filteredLocations: [Location] = []
    let cellReuseIdendifier = "LocationTableCell"
    @IBOutlet weak var mapView: MKMapView!
    var markerOrder: MapPlaceMark!
    var filteredRegions:[String] = []
    var filteredServices:[String] = []
    var filteredBasins : [String] = []
    var selectedLocation: Location?
    var locationManager:CLLocationManager!
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.mapView.isHidden = true
        setupUI()
        loadLocations(showLoader: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        AppController.shared.addNavigationButtons(navigationItem: self.navigationItem)
    }

    
    @objc func menuBtnAction() {
        presentLeftMenuViewController()
    }
    
    @objc func logoutAction() {
        AppController.shared.logoutAction()
    }
    
    @IBAction func mapSwitchTapped(_ sender: UIButton) {
        
//        self.tblView.isHidden = !self.tblView.isHidden
        if self.filteredLocations.count>0 {
            let indexPath = NSIndexPath(row: 0, section: 0)
            self.tblView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        } else {
            self.tblView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
        
        addTransitionEffect(view: self.mapView)
        self.mapView.isHidden = !self.mapView.isHidden
        if self.mapView.isHidden == false {
            let mapModel = MapViewModel(locations: self.filteredLocations, mapView: self.mapView)
            mapModel.loadDetails()
        }
        sender.isSelected = !sender.isSelected
    }
    
    func setupUI() {
        self.tblView.estimatedRowHeight = 160
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.register(UINib.init(nibName: cellReuseIdendifier, bundle: nil), forCellReuseIdentifier: cellReuseIdendifier)
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            self.tblView.refreshControl = refreshControl
        } else {
            self.tblView.backgroundView = refreshControl
        }
        
        
        
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        self.refreshControl.endRefreshing()
        loadLocations(showLoader: true)
    }
    
    func loadLocations(showLoader:Bool) {
        if showLoader {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Please wait.."
        }
        
        filteredRegions = []
        filteredBasins = []
        filteredServices = []
        
        NetworkManager().get(method: .getAllLocations, parameters: [:]) { (result, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.refreshControl.endRefreshing()
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
                    let mapModel = MapViewModel(locations: self.filteredLocations, mapView: self.mapView)
                    mapModel.loadDetails()
                }
            }
        }
    }
    
}


extension LocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredLocations.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = TableSectionHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 90))
        view.titleLbl.text = "Locations"
        view.backgroundColor = self.view.backgroundColor
        view.filterBtnAction = {
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
                
                let mapModel = MapViewModel(locations: self.filteredLocations, mapView: self.mapView)
                mapModel.loadDetails()
                
            }
            self.present(filterView, animated: true) {
                if self.filteredLocations.count>0 {
                    let indexPath = NSIndexPath(row: 0, section: 0)
                    self.tblView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                } else {
                    self.tblView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                }
            }
        }
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
            self.selectedLocation = loc
            self.determineMyCurrentLocation()
        }
        cell.phoneAction = { loc in
            print("Phone aciton")
            self.selectedLocation = loc
            if let phoneNumber = loc.phone,let phoneNumberUrl = URL(string: "tel://001\(phoneNumber)"){
                UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
            }
        }
        
        return cell
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
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
        
        
        let views = Bundle.main.loadNibNamed("LocationPopView", owner: nil, options: nil)
        let calloutView = views?[0] as! LocationPopView
        
        calloutView.titleLbl.text = starbucksAnnotation.location.getTitle()
        calloutView.addressLbl.text = starbucksAnnotation.location.getAddress()
        calloutView.phoneLbl.text = starbucksAnnotation.location.phone
        calloutView.regionLbl.text = starbucksAnnotation.location.region
        calloutView.servicesLbl.text = starbucksAnnotation.location.services
        calloutView.basinLbl.text = starbucksAnnotation.location.basins
        calloutView.location = starbucksAnnotation.location
        calloutView.locationAction = { loc in
            print("Location action")
            self.selectedLocation = loc
            self.determineMyCurrentLocation()
        }
        calloutView.phoneAction = { loc in
            print("Phone aciton")
            self.selectedLocation = loc
            if let phoneNumber = loc.phone,let phoneNumberUrl = URL(string: "tel://001\(phoneNumber)"){
                UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
            }
        }

//        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
//        let calloutView = views?[0] as! CustomCalloutView
//        calloutView.starbucksName.text = starbucksAnnotation.title
//        calloutView.starbucksAddress.text = starbucksAnnotation.address
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        mapView.setCenter((view.annotation?.coordinate)!, animated: true)
//        calloutView.iconbtn.addTarget(self, action: #selector(popup), for: .touchUpInside)
        
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


extension LocationsViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations.last! as CLLocation
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let fromLocation = (userLocation.coordinate.latitude,userLocation.coordinate.longitude)
        
        if let location = self.selectedLocation{
            let toLocation = (location.latitude ?? "0,0",location.longitude ?? "0,0")
            self.showRoute(fromLocation: fromLocation, toLocation: toLocation)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func showRoute(fromLocation inputFromLocation:(Double,Double),toLocation inputToLocation:(String,String)){
        
        let from = (String(inputFromLocation.0),String(inputFromLocation.1))
        // let from = ("44.328310","-105.452780")
        
        let directionsURL = String(format:"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@",from.0,from.1,inputToLocation.0,inputToLocation.1)
        let urlString = directionsURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: urlString!) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
}

