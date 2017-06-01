//
//  MyVenuesViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/12/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class MyVenuesViewController: UIViewController {
    
    let emptyTableText = "It looks like you don't have any venues!"
    
    let nc = NotificationCenter.default
    
    var tableViewDataSource: OGVenueTableViewDataSource?
    
    var tableViewDelegate: OGVenueTableViewDelegate?
    
    var chosenVenue: OGVenue?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
        
        tableViewDataSource = OGVenueTableViewDataSource(tableView,
                                                         type: OGVenueType.MINE,
                                                         noDataText: emptyTableText)
        tableViewDelegate = OGVenueTableViewDelegate(tableView,
                                                     type: OGVenueType.MINE,
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
    
    func didSelectVenue(venue: OGVenue) {
        chosenVenue = venue
        self.performSegue(withIdentifier: "toControlFromMyVenues", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toControlFromMyVenues" && sender != nil {
            let ovc : ChooseDeviceViewController = segue.destination as! ChooseDeviceViewController
            ovc.venue = chosenVenue
        }
    }

}
