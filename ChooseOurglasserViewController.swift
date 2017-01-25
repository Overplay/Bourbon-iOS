//
//  ChooseOurglasserViewController
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import PKHUD
import PromiseKit

class ChooseOurglasserViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
 
    @IBOutlet var mainStatusLabel: UILabel!
    @IBOutlet var ourglasserCollection : UICollectionView!
    
    let SEARCHING_TIMEOUT_INTERVAL = 7.0
    
    let isDevelopment = Settings.sharedInstance.isDevelopmentMode
    
    let nc = NotificationCenter.default
    var refreshControl : UIRefreshControl!
    var refreshing = true
    
    var availableOPIEs = [OPIE]()
    var iphoneIPAddress = String()
    
    var shouldFindAfterAppear = true
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for OPIE notifications
        nc.addObserver(self, selector: #selector(newOPIE), name: NSNotification.Name(rawValue: ASNotification.newOg.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(OPIESocketError), name: NSNotification.Name(rawValue: ASNotification.ogSocketError.rawValue), object: nil)
        nc.addObserver(self, selector: #selector(droppedOPIE), name: NSNotification.Name(rawValue: ASNotification.droppedOg.rawValue), object: nil)

        // Setup collection view
        self.ourglasserCollection.dataSource = self
        self.ourglasserCollection.delegate = self
        self.ourglasserCollection.allowsMultipleSelection = false
        
        // Setup refresh control and add
        self.refreshControl = UIRefreshControl()
        //self.refreshControl.tintColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha:1)
        self.refreshControl.addTarget(self, action: #selector(findOurglassers), for: UIControlEvents.valueChanged)
        self.ourglasserCollection.addSubview(self.refreshControl)
        self.ourglasserCollection.alwaysBounceVertical = true
        
        setNeedsStatusBarAppearanceUpdate()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO fix fix
        //log.info(NetUtils.getWifiInfo()!.description)
        
        self.navigationController?.isNavigationBarHidden = true

        
        if shouldFindAfterAppear {
            shouldFindAfterAppear = false
            self.findOurglassers()
        }
    }
    
//    // Delegate method to start finding after intro is finished
//    func introDidFinish(introView: EAIntroView!, wasSkipped: Bool) {
//        // Begin searching
//        self.findOurglassers()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newOPIE() {
        log.debug("New OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func droppedOPIE() {
        log.debug("Dropped OPIE")
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        self.stopRefresh()
    }
    
    func OPIESocketError() {
        self.refreshControl.endRefreshing()
        
        HUD.hide()
        
        let alertController = UIAlertController(title: "OPIE Locator", message: "There was an error locating OPIEs.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    

    func findOurglassers() {
        
        // Run a sweep...
        OPIEBeaconListener.sharedInstance.broadcastPacket()
        
        self.refreshing = true
        self.refreshControl.beginRefreshing()
        
        mainStatusLabel.text = Network.wifiSSID() ?? "NOT CONNECTED"
        
        self.availableOPIEs = OPIEBeaconListener.sharedInstance.opies
        
        // Stops the spinner if we have seen no added/dropped OPIEs in 5s
        Timer.scheduledTimer(timeInterval: SEARCHING_TIMEOUT_INTERVAL, target: self, selector: #selector(stopRefresh), userInfo: nil, repeats: false)
    }
    
    func stopRefresh() {
        self.refreshing = false
        self.refreshControl.endRefreshing()
        self.sortByIPAndReload()
    }
    
    func sortByIPAndReload() {
        if self.availableOPIEs.count > 1 {
            self.availableOPIEs.sort {
                (a : OPIE, b : OPIE) -> Bool in
                let comp = a.ipAddress.compare(b.ipAddress, options: NSString.CompareOptions.numeric)
                if comp == ComparisonResult.orderedAscending {
                    return true
                } else {
                    return false
                }
            }
        }
        self.ourglasserCollection.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.availableOPIEs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : OurglasserCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DefaultOurglasserCell", for: indexPath) as! OurglasserCell
        
//        cell.image.image = self.availableOPIEs[indexPath.row].icon
        cell.name.text = self.availableOPIEs[indexPath.row].systemName
        cell.location.text = self.availableOPIEs[indexPath.row].location
        //cell.ipAddress.text = (isDevelopment ? self.availableOPIEs[indexPath.row].ipAddress : "")
        cell.ipAddress.text = self.availableOPIEs[indexPath.row].ipAddress
        cell.systemNumberLabel.text = String(format: "%02d", indexPath.row + 1)
        
        // Make number red for devices without a venue
        if (self.availableOPIEs[indexPath.row].venue == "") {
            cell.systemNumberLabel.textColor = UIColor.red
        } else {
            cell.systemNumberLabel.textColor = UIColor.white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toOPControl", sender: indexPath)
    }
    
    // Set header view height low if we're not showing the error message, why would we want a huge blank space?
    // Set the '' to however tall it is in the storyboard
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.availableOPIEs.count < 1 && !self.refreshing ? CGSize(width: 330, height: 100) : CGSize(width: 330, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
             let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            
            if self.availableOPIEs.count < 1 && !self.refreshing {
                headerView.isHidden = false
            } else {
                headerView.isHidden = true
            }
            
       
        return headerView

        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.refreshControl.endRefreshing()
        
        if segue.identifier == "toOPControl" && sender != nil {
            let indexPath: IndexPath = sender as! IndexPath
            let op = self.availableOPIEs[indexPath.row]
            let ovc : OurglasserViewController = segue.destination as! OurglasserViewController
            ovc.goToUrl = op.getDecachedUrl()
            ovc.navTitle = op.location
            ovc.op = op
            ovc.chooseViewController = self
        }
    }

}

