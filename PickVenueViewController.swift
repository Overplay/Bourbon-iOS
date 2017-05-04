//
//  PickVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

protocol PickVenueViewControllerDelegate {
    func pickVenue(_ venue: OGVenue)
}

class PickVenueViewController: UIViewController {
    
    var delegate: PickVenueViewControllerDelegate?
    var tableViewDataSource: VenueTableViewDataSource?

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addVenue(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
        

        self.tableViewDataSource = VenueTableViewDataSource(tableView: tableView, type: VenueType.MINE)
        tableView.delegate = self
        
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
        if self.delegate != nil {
            self.delegate!.pickVenue(StateController.sharedInstance.myVenues[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
}
