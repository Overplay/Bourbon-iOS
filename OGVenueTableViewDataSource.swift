//
//  OGVenueTableViewDaraSource.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

enum VenueType {
    case ALL, MINE
}

class OGVenueTableViewDataSource: NSObject {
    
    var type: VenueType = VenueType.ALL
    var noDataText: String
    
    init(tableView: UITableView, type: VenueType, noDataText: String) {
        self.type = type
        self.noDataText = noDataText
        super.init()
        tableView.dataSource = self
    }
}

extension OGVenueTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch type {
        case VenueType.ALL:
            rows = StateController.sharedInstance.allVenues.count
        case VenueType.MINE:
            rows = StateController.sharedInstance.myVenues.count
        }
        
        if rows == 0 {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = self.noDataText
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: Style.regularFont, size: 12.0)
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        } else {
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
            venue = StateController.sharedInstance.myVenues[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OGVenueTableCell.identifier, for: indexPath) as! OGVenueTableCell
        
        cell.name.text = venue.name
        cell.address.text = venue.address
        return cell
    }
}
