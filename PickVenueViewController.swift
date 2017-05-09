//
//  PickVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

protocol PickVenueViewControllerDelegate {
    func selectVenue(_ venue: OGVenue)
}

class PickVenueViewController: UIViewController {
    
    var delegate: PickVenueViewControllerDelegate?
    var tableViewDataSource: VenueTableViewDataSource?

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
    
        self.tableViewDataSource = VenueTableViewDataSource(tableView: tableView, type: VenueType.MINE)
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
    }
}

extension PickVenueViewController: CreateVenueViewControllerDelegate {
    func createdVenue(_ venue: OGVenue) {
        if let del = self.delegate {
            del.selectVenue(venue)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension PickVenueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let del = self.delegate {
            del.selectVenue(StateController.sharedInstance.myVenues[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}
