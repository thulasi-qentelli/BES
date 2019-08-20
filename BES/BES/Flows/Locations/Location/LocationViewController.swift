//
//  LocationViewController.swift
//  BES
//
//  Created by Prathyusha Chiluveru on 29/07/19.
//  Copyright © 2019 Prathyusha Chiluveru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

enum FilterOption{
    case region,service,basin
}

class LocationViewController: UIViewController {
    
    fileprivate var viewModel : LocationViewModel!
    fileprivate var router    : LocationRouter!
    let disposeBag            = DisposeBag()
    var expandedRow  : Int?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnProfle: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var vwFilter3 : UIView!
    @IBOutlet weak var vwFilter2 : UIView!
    @IBOutlet weak var vwFilter1 : UIView!
    @IBOutlet weak var btnClose3 : UIButton!
    @IBOutlet weak var btnClose2 : UIButton!
    @IBOutlet weak var btnClose1 : UIButton!
    @IBOutlet weak var lblFilter3 : UILabel!
    @IBOutlet weak var lblFilter2 : UILabel!
    @IBOutlet weak var lblFilter1 : UILabel!
    @IBOutlet weak var btnClearAll : UIButton!
    @IBOutlet weak var selectionView : UIView!
    @IBOutlet weak var tblLocation : UITableView!
    @IBOutlet weak var btnProfile : UIButton!
    @IBOutlet weak var allRegionsView : UIView!
    @IBOutlet weak var allServicesView : UIView!
    @IBOutlet weak var allBasinsView : UIView!
    
    @IBOutlet weak var allRegionsButton : UIButton!
    @IBOutlet weak var allServicesButton : UIButton!
    @IBOutlet weak var allBasinsButton : UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    var markerOrder: MapPlaceMark!
    
    let locationCellReuseIdentifier = "LocationCellReuseIdentifier"
    let expandedlocationCellReuseIdentifier = "ExpandedLocationCellReuseIdentifier"
    
    var selectedRegion  : String?
    var selectedService : String?
    var selectedBasin   : String?
    var filterOption    : FilterOption?
    var allLabels : [UILabel]?
    var locationManager:CLLocationManager!

    
    init(with viewModel:LocationViewModel,_ router:LocationRouter){
        
        self.viewModel = viewModel
        self.router    = router
        super.init(nibName: "LocationViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpRx()
        viewModel.getLocations()
        headerView.dropShadow()
        
        if let userImage = appDelegate.user?.pic{
            var urlString = userImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(red:0.09, green:0.12, blue:0.24, alpha:0.1).cgColor
        
        btnClose1.tag = 0
        btnClose2.tag = 1
        btnClose3.tag = 2
        self.allLabels = [lblFilter1,lblFilter2,lblFilter3]
        
        btnClose1.addTarget(self, action: #selector(deleteFilter(sender:)), for: .touchUpInside)
        btnClose2.addTarget(self, action: #selector(deleteFilter(sender:)), for: .touchUpInside)
        btnClose3.addTarget(self, action: #selector(deleteFilter(sender:)), for: .touchUpInside)
        btnClearAll.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        
        vwFilter1.layer.cornerRadius = 10
        vwFilter1.clipsToBounds = true
        vwFilter2.layer.cornerRadius = 10
        vwFilter2.clipsToBounds = true
        vwFilter3.layer.cornerRadius = 10
        vwFilter3.clipsToBounds = true
        
        btnClearAll.layer.borderColor = UIColor(red:0.99, green:0.4, blue:0.1, alpha:1).cgColor
        btnClearAll.layer.borderWidth = 1
        btnClearAll.layer.cornerRadius = 14.5
        
        
        selectionView.isHidden = true
        btnClearAll.isHidden = true
        vwFilter1.isHidden = true
        vwFilter2.isHidden = true
        vwFilter3.isHidden = true
        
        
        btnProfile.layer.cornerRadius = btnProfile.frame.width/2
        btnProfile.clipsToBounds = true

        tblLocation.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: locationCellReuseIdentifier)
        tblLocation.register(UINib(nibName: "ExpandedLocationTableViewCell", bundle: nil), forCellReuseIdentifier: expandedlocationCellReuseIdentifier)
        tblLocation.delegate = self
        tblLocation.dataSource = self
        //tblFeed.estimatedRowHeight = UITableView.automaticDimension
        tblLocation.tableFooterView = UIView()
        
        allRegionsView.layer.cornerRadius = 4
        allRegionsView.layer.borderWidth = 1
        allRegionsView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        allServicesView.layer.cornerRadius = 4
        allServicesView.layer.borderWidth = 1
        allServicesView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        allBasinsView.layer.cornerRadius = 4
        allBasinsView.layer.borderWidth = 1
        allBasinsView.layer.borderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1).cgColor
        
        btnProfile.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        allRegionsButton.addTarget(self, action: #selector(showRegionFilter), for: .touchUpInside)
        allServicesButton.addTarget(self, action: #selector(showServicesFilter), for: .touchUpInside)
        allBasinsButton.addTarget(self, action: #selector(showBasinsFilter), for: .touchUpInside)
    
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
    
    func setUpRx(){
        
        viewModel.didGetLocations.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                guard success == true else{ self.showAlertWith(title: "Error", message: "Please try again.", action: "OK"); return}
                
                self.viewModel.filteredLocations = self.viewModel.locations
                self.viewModel.getRegions()
                self.viewModel.getBasins()
                self.viewModel.getServices()
                
                self.lblTitle.text = "Locations (\(self.viewModel.filteredLocations.count))"
                self.tblLocation.reloadData()
                
                let mapModel = MapViewModel(locations: self.viewModel.filteredLocations, mapView: self.mapView)
                mapModel.loadDetails()
                
            }).disposed(by: disposeBag)
        
        viewModel.didFilterOptions.skip(1).asObservable()
            .subscribe(onNext:{ success in
                
                self.lblTitle.text = "Locations (\(self.viewModel.filteredLocations.count))"
                self.tblLocation.reloadData()
                
                let mapModel = MapViewModel(locations: self.viewModel.filteredLocations, mapView: self.mapView)
                mapModel.loadDetails()
                
            }).disposed(by: disposeBag)
    }
    
    @IBAction func mapSwitchTapped(_ sender: UIButton) {
        self.tblLocation.isHidden = !self.tblLocation.isHidden
        sender.isSelected = !sender.isSelected
    }
    @objc func deleteFilter(sender:UIButton){
        
        let currentLabel = allLabels![sender.tag]
        
        let selectedFilter = currentLabel.text
        
        if selectedRegion == selectedFilter{
            
            self.selectedRegion = nil
            
        }else if selectedService == selectedFilter{
            
            self.selectedService = nil
            
        }else if selectedBasin == selectedFilter{
            
            self.selectedBasin = nil
        }
        
        applyFilters()
    }
    
    @objc func clearAll(){
        
        self.selectionView.isHidden = true
        self.selectedService = nil
        self.selectedRegion = nil
        self.selectedBasin = nil
        self.viewModel.filteredLocations = self.viewModel.locations
        tblLocation.reloadData()
        let mapModel = MapViewModel(locations: self.viewModel.filteredLocations, mapView: self.mapView)
        mapModel.loadDetails()
    }
    
    @objc func showProfile(){
        
        self.router.navigateToProfile()
    }
    
    @objc func showRegionFilter(){
        
        self.filterOption = FilterOption.region
        
        let vc = FilterViewController()
        vc.options = self.viewModel.regions
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        if let unwrappedSelectedRegion = self.selectedRegion{
            for i in 0...self.viewModel.regions.count-1{
                let currentRegion = self.viewModel.regions[i]
                if currentRegion == unwrappedSelectedRegion{
                    vc.selectedRow = i+1
                }
            }
        }
    
        present(vc, animated: true, completion: nil)
    }
    
    @objc func showServicesFilter(){
        
        self.filterOption = FilterOption.service
        
        let vc = FilterViewController()
        vc.options = self.viewModel.services
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        if let unwrappedSelectedServie = self.selectedService{
            for i in 0...self.viewModel.services.count-1{
                let currentService = self.viewModel.services[i]
                if currentService == unwrappedSelectedServie{
                    vc.selectedRow = i+1
                }
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc func showBasinsFilter(){
        
        self.filterOption = FilterOption.basin
        
        let vc = FilterViewController()
        vc.options = self.viewModel.basins
        vc.delegate = self
        vc.modalPresentationStyle = .custom
        if let unwrappedSelectedBasin = self.selectedBasin{
            for i in 0...self.viewModel.basins.count-1{
                let currentBasin = self.viewModel.basins[i]
                if currentBasin == unwrappedSelectedBasin{
                    vc.selectedRow = i+1
                }
            }
        }
        present(vc, animated: true, completion: nil)
    }
    
    
    func showAlertWith(title inputTitle:String,message inputMessage:String,action inputAction:String){
        
        let alertVC = UIAlertController(title: inputTitle, message:inputMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title:inputAction, style: .default, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}


extension LocationViewController : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.filteredLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let expandedRow = self.expandedRow{
            
            if expandedRow == indexPath.row {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: expandedlocationCellReuseIdentifier, for: indexPath) as! ExpandedLocationTableViewCell
                
                cell.isUserInteractionEnabled = true
                cell.btnCollapse.tag = indexPath.row
                cell.btnCollapse.addTarget(self, action: #selector(expandCell), for:.touchUpInside)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMaps))
                cell.lblAddress.isUserInteractionEnabled = true
                cell.lblAddress.addGestureRecognizer(tapGesture)
                
                cell.btnPhoneNumber.tag = indexPath.row
                cell.btnPhoneNumber.addTarget(self, action: #selector(phoneNumberTapped(sender:)), for:.touchUpInside)
                
                let currentLocation = self.viewModel.filteredLocations[indexPath.row]
                cell.configureWith(currentLocation)
                
                return cell
                
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellReuseIdentifier, for: indexPath) as! LocationTableViewCell
        
        cell.isUserInteractionEnabled = true
        cell.btnExpand.tag = indexPath.row
        cell.btnExpand.addTarget(self, action: #selector(expandCell), for:.touchUpInside)
        
        let currentLocation = viewModel.filteredLocations[indexPath.row]
        cell.configure(with: currentLocation)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let expandedRow = self.expandedRow{
            
            if expandedRow == indexPath.row {
                
                return 390
                
            }
        }
        
        return 126
    }
    
    @objc func expandCell(sender:UIButton){
        
        if let expandedRow = self.expandedRow{
            if expandedRow == sender.tag{
                self.expandedRow = nil
                self.tblLocation.reloadData()
                return
            }
        }
        
        self.expandedRow = sender.tag
        tblLocation.reloadData()
        
    }
    
    @objc func phoneNumberTapped(sender:UIButton){
        
        let expandedLocation = self.viewModel.filteredLocations[sender.tag]
        
        if let phoneNumber = expandedLocation.phone,let phoneNumberUrl = URL(string: "tel://001\(phoneNumber)"){
            UIApplication.shared.open(phoneNumberUrl, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openMaps(){
        
        self.determineMyCurrentLocation()
    }
}

extension LocationViewController : FilterViewControllerDelegate{
    
    func didSelectOption(_ option:String){
        
        self.selectionView.isHidden = false
        self.btnClearAll.isHidden = false
        
        if let unwrappedFilterOpiton = self.filterOption{
            
            switch unwrappedFilterOpiton{
                
            case .region  : self.selectedRegion = option

            case .service : self.selectedService = option
                
            case .basin   : self.selectedBasin = option
            
            }
        }
        
        self.applyFilters()
    }
    
    func applyFilters(){
        
        if let region = selectedRegion,let service = selectedService ,let basin = selectedBasin{
            vwFilter1.isHidden = false
            vwFilter2.isHidden = false
            vwFilter3.isHidden = false
            
            lblFilter1.text = region
            lblFilter2.text = service
            lblFilter3.text = basin
        }
        
        if let region = selectedRegion,let service = selectedService ,selectedBasin==nil{
            vwFilter1.isHidden = false
            vwFilter2.isHidden = false
            vwFilter3.isHidden = true
            
            lblFilter1.text = region
            lblFilter2.text = service
        }
        
        if let region = selectedRegion,selectedService==nil ,let basin = selectedBasin{
            vwFilter1.isHidden = false
            vwFilter2.isHidden = false
            vwFilter3.isHidden = true
            
            lblFilter1.text = region
            lblFilter2.text = basin
        }
        
        if selectedRegion==nil,let service = selectedService ,let basin = selectedBasin{
            vwFilter1.isHidden = false
            vwFilter2.isHidden = false
            vwFilter3.isHidden = true
            
            lblFilter1.text = service
            lblFilter2.text = basin
        }
        
        if let region = selectedRegion,selectedService==nil,selectedBasin==nil{
            vwFilter1.isHidden = false
            lblFilter1.text = region
            
            vwFilter2.isHidden = true
            vwFilter3.isHidden = true
            
        }
        
        if selectedRegion==nil,let service = selectedService ,selectedBasin==nil{
            vwFilter1.isHidden = false
            lblFilter1.text = service
            
            vwFilter2.isHidden = true
            vwFilter3.isHidden = true
        }
        
        if selectedRegion==nil,selectedService==nil ,let basin = selectedBasin{
            vwFilter1.isHidden = false
            lblFilter1.text = basin
            
            vwFilter2.isHidden = true
            vwFilter3.isHidden = true
        }
        
        if selectedRegion==nil,selectedService==nil ,selectedBasin==nil{
            self.selectionView.isHidden = true
        }
        
        self.viewModel.filterRegionsWith(region: self.selectedRegion, service: self.selectedService, basin: self.selectedBasin)
    }
}

extension LocationViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations.last! as CLLocation
        manager.stopUpdatingLocation()
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let fromLocation = (userLocation.coordinate.latitude,userLocation.coordinate.longitude)
        
        if let unwrappedExpandedRow = self.expandedRow{
            let expandedLocation = self.viewModel.filteredLocations[unwrappedExpandedRow]
            if let unwrappedLatitude = expandedLocation.latitude,let unwrappedLongitude = expandedLocation.longitude{
                let toLocation = (unwrappedLatitude,unwrappedLongitude)
                self.showRoute(fromLocation: fromLocation, toLocation: toLocation)
            }
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


extension LocationViewController: MKMapViewDelegate {
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
