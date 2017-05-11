//
//  OGVenueTableViewDaraSource.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

/// Identifies the type of venues to associate with the table.
///
/// - ALL: all venues
/// - MINE: only venues associated with the current user (owned and managed)
/// - OWNED: only the venues the current user owns
/// - MANAGED: only the venues the current user manages
enum VenueType {
    case ALL, MINE, OWNED, MANAGED
}

/// `UITableView` data source that is used to provide the table with `OGVenue` data.
class OGVenueTableViewDataSource: NSObject {
    
    /// Used to identify which venues to use in the table.
    var type: VenueType
    
    /// Text to display when there is no data in the table.
    var noDataText: String
    
    init(tableView: UITableView, type: VenueType, noDataText: String) {
        self.type = type
        self.noDataText = noDataText
        super.init()
        tableView.dataSource = self
    }
}

extension OGVenueTableViewDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case VenueType.ALL:
            return 1
        case VenueType.MINE:
            return StateController.sharedInstance.myVenues.count
        case VenueType.OWNED:
            return 1
        case VenueType.MANAGED:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch type {
        case VenueType.MINE:
            return StateController.sharedInstance.myVenues[section].label
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch type {
        case VenueType.ALL:
            rows = StateController.sharedInstance.allVenues.count
        case VenueType.MINE:
            rows = StateController.sharedInstance.myVenues[section].venues.count
        case VenueType.OWNED:
            rows = StateController.sharedInstance.ownedVenues.count
        case VenueType.MANAGED:
            rows = StateController.sharedInstance.managedVenues.count
        }
        
        if rows == 0 && type != VenueType.MINE { // display a message indicating there is no data
            
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
        case VenueType.ALL:
            venue = StateController.sharedInstance.allVenues[indexPath.row]
        case VenueType.MINE:
            venue = StateController.sharedInstance.myVenues[indexPath.section].venues[indexPath.row]
        case VenueType.OWNED:
            venue = StateController.sharedInstance.ownedVenues[indexPath.row]
        case VenueType.MANAGED:
            venue = StateController.sharedInstance.managedVenues[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OGVenueTableCell.identifier, for: indexPath) as! OGVenueTableCell
        
        cell.name.text = venue.name
        cell.address.text = venue.address
        
        cell.selectionStyle = .none
        
        return cell
    }
}
