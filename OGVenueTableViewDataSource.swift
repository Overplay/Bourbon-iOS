//
//  OGVenueTableViewDaraSource.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

/// `UITableView` data source that is used to provide the table with `OGVenue` data.
class OGVenueTableViewDataSource: NSObject {
    
    /// Used to identify which venues to use in the table.
    var type: OGVenueType
    
    /// Text to display when there is no data in the table.
    var noDataText: String
    
    init(_ tableView: UITableView, type: OGVenueType, noDataText: String) {
        self.type = type
        self.noDataText = noDataText
        super.init()
        tableView.dataSource = self
    }
}

extension OGVenueTableViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case OGVenueType.ALL:
            return 1
        case OGVenueType.MINE:
            return StateController.sharedInstance.myVenues.count
        case OGVenueType.OWNED:
            return 1
        case OGVenueType.MANAGED:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch type {
        case OGVenueType.MINE:
            return StateController.sharedInstance.myVenues[section].label
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch type {
        case OGVenueType.ALL:
            rows = StateController.sharedInstance.allVenues.count
        case OGVenueType.MINE:
            rows = StateController.sharedInstance.myVenues[section].venues.count
        case OGVenueType.OWNED:
            rows = StateController.sharedInstance.ownedVenues.count
        case OGVenueType.MANAGED:
            rows = StateController.sharedInstance.managedVenues.count
        }
        
        if rows == 0 && type != OGVenueType.MINE { // display a message indicating there is no data
            
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = self.noDataText
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: Style.regularFont, size: 12.0)
            
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            
        } else { // there is data, so make sure the "no data" view is gone
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let venue: OGVenue
        
        switch type {
        case OGVenueType.ALL:
            venue = StateController.sharedInstance.allVenues[indexPath.row]
        case OGVenueType.MINE:
            venue = StateController.sharedInstance.myVenues[indexPath.section].venues[indexPath.row]
        case OGVenueType.OWNED:
            venue = StateController.sharedInstance.ownedVenues[indexPath.row]
        case OGVenueType.MANAGED:
            venue = StateController.sharedInstance.managedVenues[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OGVenueTableCell.identifier, for: indexPath) as! OGVenueTableCell
        
        cell.name.text = venue.name
        cell.address.text = venue.address
        
        cell.selectionStyle = .none
        
        return cell
    }
}
