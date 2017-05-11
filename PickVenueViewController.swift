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

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pick a venue"
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
    
        self.tableViewDataSource = OGVenueTableViewDataSource(tableView: tableView, type: VenueType.MINE, noDataText: emptyTableText)
        tableView.delegate = self
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
}

extension PickVenueViewController: CreateVenueViewControllerDelegate {
    func createdVenue(_ venue: OGVenue) {
        // refresh venues list
        StateController.sharedInstance.findMyVenues()
            .then { _ -> Void in
                self.tableView.reloadData()
            }
            .catch { err -> Void in
                log.debug(err)
        }
    }
}

extension PickVenueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromPickVenueToSetup",
                     sender: StateController.sharedInstance.myVenues[indexPath.section].venues[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(name: Style.mediumFont, size: 11.0)
            header.textLabel?.textColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
