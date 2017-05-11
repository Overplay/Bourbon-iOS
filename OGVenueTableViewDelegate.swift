//
//  OGVenueTableViewDelegate.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/11/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

/// `UITableView` delegate based on `OGVenue` data stored in `StateController`.
class OGVenueTableViewDelegate: NSObject {
    
    /// used to identify which venues to use in the table
    var type: OGVenueType
    
    /// function to call when a table view cell is selected
    var didSelect: (OGVenue) -> Void
    
    /// height of each table view cell
    var rowHeight: CGFloat
    
    /// font for the headers, if there are any
    var headerFont: UIFont
    
    /// text color for the headers, if there are any
    var headerTextColor: UIColor
    
    init(_ tableView: UITableView, type: OGVenueType,
         didSelect: @escaping (OGVenue) -> Void,
         rowHeight: CGFloat = 60.0,
         headerFont: UIFont = UIFont(name: Style.mediumFont, size: 11.0)!,
         headerTextColor: UIColor = UIColor.white) {
        
        self.type = type
        self.didSelect = didSelect
        self.rowHeight = rowHeight
        self.headerFont = headerFont
        self.headerTextColor = headerTextColor
        
        super.init()
        tableView.delegate = self
    }
}

extension OGVenueTableViewDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        
        self.didSelect(venue)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = self.headerFont
            header.textLabel?.textColor = self.headerTextColor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
}
