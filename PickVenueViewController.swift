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
    
    var tableViewDataSource: OGVenueTableViewDataSource?
    
    var tableViewDelegate: OGVenueTableViewDelegate?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick a venue"
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
    
        tableViewDataSource = OGVenueTableViewDataSource(tableView,
                                                         type: OGVenueType.OWNED,
                                                         noDataText: emptyTableText)
        tableViewDelegate = OGVenueTableViewDelegate(tableView,
                                                     type: OGVenueType.OWNED,
                                                     didSelect: didSelectVenue)
        tableView.tableFooterView = UIView(frame: .zero)
        
        StateController.sharedInstance.findMyVenues()
            .then { _ -> Void in
                self.tableView.reloadData()
        }
            .catch { err -> Void in
                log.debug(err)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CreateVenueViewController {
            vc.delegate = self
        }
        
        if let vc = segue.destination as? SetupDeviceViewController,
            let venue = sender as? OGVenue {
            vc.selectedVenue = venue
        }
    }
    
    func didSelectVenue(venue: OGVenue) {
        performSegue(withIdentifier: "fromPickVenueToSetup", sender: venue)
    }
}

extension PickVenueViewController: CreateVenueViewControllerDelegate {
    
    func createdVenue(_ venue: OGVenue) {
        // refresh venues list to get the new venue
        StateController.sharedInstance.findMyVenues()
            .then { _ -> Void in
                self.tableView.reloadData()
            }
            .catch { err -> Void in
                log.debug(err)
        }
    }
}
