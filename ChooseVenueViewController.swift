//
//  ChooseVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/10/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD
import PromiseKit
import SwiftyJSON
import CoreLocation

class ChooseVenueViewController : UIViewController,
    UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate  {
    
    @IBOutlet weak var venueCollection: UICollectionView!
    
    let SEARCHING_TIMEOUT_INTERVAL = 7.0
    
    var refreshControl : UIRefreshControl!
    var refreshing = true
    
    let locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    
    var venues = [OGVenue]()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup collection view
        self.venueCollection.dataSource = self
        self.venueCollection.delegate = self
        self.venueCollection.allowsMultipleSelection = false
        
        // Setup refresh control and add
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(findVenues), for: UIControlEvents.valueChanged)
        self.venueCollection.addSubview(self.refreshControl)
        self.venueCollection.alwaysBounceVertical = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // for use in the foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.findVenues()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findVenues() {
        self.refreshing = true
        self.refreshControl.beginRefreshing()
        
        StateController.sharedInstance.findAllVenues()
            .then { _ -> Void in
                self.venues = StateController.sharedInstance.allVenues
                self.sortByLocationAndReload()
                self.stopRefresh()
            }
            .catch { _ in
                log.error("Error getting venues")
                self.sortByLocationAndReload()
                self.stopRefresh()
        }
        
        // Stops the spinner if we have seen no venues
        Timer.scheduledTimer(timeInterval: SEARCHING_TIMEOUT_INTERVAL, target: self, selector: #selector(stopRefresh), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.refreshing = false
        self.refreshControl.endRefreshing()
    }
    
    func sortByLocationAndReload() {
        guard let curLocObj = self.location else {
            self.venueCollection.reloadData()
            return
        }
     
        self.venues.sort { (a : OGVenue, b : OGVenue) -> Bool in
                
            let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
            let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
            let curLoc = CLLocation(latitude: curLocObj.latitude, longitude: curLocObj.longitude)
                
            return locA.distance(from: curLoc) < locB.distance(from: curLoc)
        }
        
        self.venueCollection.reloadData()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last?.coordinate
        //log.debug("updated location")
        //self.findVenues()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.venues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : VenueCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultVenueCell", for: indexPath) as! VenueCell
        
        cell.name.text = self.venues[indexPath.row].name
        cell.address.text = self.venues[indexPath.row].address
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toFindDevice", sender: indexPath)
    }
    
    // Set header view height low if we're not showing the error message
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.venues.count < 1 && !self.refreshing ? CGSize(width: 330, height: 100) : CGSize(width: 330, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
        
        if self.venues.count < 1 && !self.refreshing {
            headerView.isHidden = false
        } else {
            headerView.isHidden = true
        }
        
        return headerView
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.refreshControl.endRefreshing()
        
        if segue.identifier == "toFindDevice" && sender != nil {
            let indexPath: IndexPath = sender as! IndexPath
            let venue = self.venues[indexPath.row]
            let ovc : ChooseDeviceViewController = segue.destination as! ChooseDeviceViewController
            ovc.venue = venue
        }
    }
    
}
