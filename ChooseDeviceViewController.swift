//
//  ChooseDeviceViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD
import PromiseKit
import SwiftyJSON

class ChooseDeviceViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var venueNameLabel: UILabel!
    
    @IBOutlet weak var deviceCollection: UICollectionView!
    
    let SEARCHING_TIMEOUT_INTERVAL = 7.0
    
    var refreshControl : UIRefreshControl!
    var refreshing = true
    
    var devices = [OGDevice]()
    
    var venue: OGVenue!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.venueNameLabel.text = venue.name
        
        // Setup collection view
        self.deviceCollection.dataSource = self
        self.deviceCollection.delegate = self
        self.deviceCollection.allowsMultipleSelection = false
        
        // Setup refresh control and add
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(findDevices), for: UIControlEvents.valueChanged)
        self.deviceCollection.addSubview(self.refreshControl)
        self.deviceCollection.alwaysBounceVertical = true
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Devices"
        
        self.findDevices()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findDevices() {
        
        self.refreshing = true
        self.refreshControl.beginRefreshing()
        
        Asahi.sharedInstance.getDevices(self.venue.uuid)
        
            .then{ json -> Void in
                self.processDevices(json)
                self.stopRefresh()
            }
        
            .catch{ err -> Void in
                self.stopRefresh()
            }
        
        // Stops the spinner if we have seen no venues
        Timer.scheduledTimer(timeInterval: SEARCHING_TIMEOUT_INTERVAL, target: self, selector: #selector(stopRefresh), userInfo: nil, repeats: false)
    }
    
    func processDevices(_ inboundDeviceJson: JSON) {
        
        guard let devicesArray = inboundDeviceJson.array else {
            log.debug("No devices found!")
            return
        }
        
        self.devices = [OGDevice]()
        
        for device in devicesArray {
            
            let name = device["name"].stringValue
            let udid = device["deviceUDID"].stringValue
            let venueUUID = device["atVenueUUID"].stringValue
            
            self.devices.append(OGDevice(name: name, atVenueUUID: venueUUID, udid: udid))
        }
    }
    
    func stopRefresh() {
        self.refreshing = false
        self.refreshControl.endRefreshing()
        self.sortAndReload()
    }
    
    func sortAndReload() {
        /*if self.devices.count > 1 {
            self.devices.sort {
                (a : OGDevice, b : OGDevice) -> Bool in
                let comp = a.ipAddress.compare(b.ipAddress, options: NSString.CompareOptions.numeric)
                if comp == ComparisonResult.orderedAscending {
                    return true
                } else {
                    return false
                }
            }
        }*/
        self.deviceCollection.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : DeviceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultDeviceCell", for: indexPath) as! DeviceCell
        
        cell.name.text = self.devices[indexPath.row].name
        cell.numberLabel.text = String(format: "%02d", indexPath.row + 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDeviceControl", sender: indexPath)
    }
    
    // Set header view height low if we're not showing the error message
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.devices.count < 1 && !self.refreshing ? CGSize(width: 330, height: 100) : CGSize(width: 330, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
        
        if self.devices.count < 1 && !self.refreshing {
            headerView.isHidden = false
        } else {
            headerView.isHidden = true
        }
        
        return headerView
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.refreshControl.endRefreshing()
        
        if segue.identifier == "toDeviceControl" && sender != nil {
            let indexPath: IndexPath = sender as! IndexPath
            let device = self.devices[indexPath.row]
            let dvc : DeviceViewController = segue.destination as! DeviceViewController
            dvc.ogDevice = device
        }
    }
    
}
