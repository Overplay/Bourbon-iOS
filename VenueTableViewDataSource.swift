//
//  VenueTableViewDaraSource.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

enum VenueType {
    case ALL, MINE
}

class VenueTableViewDataSource: NSObject {
    
    var type: VenueType = VenueType.ALL
    
    init(tableView: UITableView, type: VenueType) {
        super.init()
        tableView.dataSource = self
        self.type = type
    }
}

extension VenueTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case VenueType.ALL:
            return StateController.sharedInstance.allVenues.count
        case VenueType.MINE:
            return StateController.sharedInstance.myVenues.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let venue: OGVenue
        
        switch type {
        case VenueType.ALL:
            venue = StateController.sharedInstance.allVenues[indexPath.row]
        case VenueType.MINE:
            venue = StateController.sharedInstance.myVenues[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VenueTableCell.identifier, for: indexPath) as UITableViewCell
        
        cell.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor( white: 1.0, alpha: 0.7)
        cell.textLabel?.font = UIFont(name: Style.regularFont, size: 15.0)
        cell.detailTextLabel?.font = UIFont(name: Style.lightFont, size: 12.0)
        
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.address
        return cell
    }
}
