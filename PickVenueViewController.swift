//
//  PickVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class PickVenueViewController: UIViewController {
    
    let emptyTableText = "It looks like you don't have any venues!"
    
    let nc = NotificationCenter.default
    
    var tableViewDataSource: OGVenueTableViewDataSource?
    
    var tableViewDelegate: OGVenueTableViewDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick a venue"
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
    
        tableViewDataSource = OGVenueTableViewDataSource(tableView,
                                                         type: OGVenueType.OWNED,
                                                         noDataText: emptyTableText,
                                                         accessory: UITableViewCellAccessoryType.disclosureIndicator)
        tableViewDelegate = OGVenueTableViewDelegate(tableView,
                                                     type: OGVenueType.OWNED,
                                                     didSelect: didSelectVenue)
        tableView.tableFooterView = UIView(frame: .zero)
        
        nc.addObserver(
            forName: NSNotification.Name(rawValue: ASNotification.myVenuesUpdated.rawValue),
            object: nil, queue: nil) { _ in
                self.tableView.reloadData()
        }
        
        StateController.sharedInstance.findMyVenues()
            .then { _ -> Void in
                self.tableView.reloadData()
        }
            .catch { err -> Void in
                log.debug(err)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? SetupDeviceViewController,
            let venue = sender as? OGVenue {
            vc.selectedVenue = venue
        }
    }
    
    func didSelectVenue(venue: OGVenue) {
        performSegue(withIdentifier: "fromPickVenueToSetup", sender: venue)
    }
}

