//
//  VenueTableCell.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class VenueTableCell: UITableViewCell {
    static let identifier = "VenueTableCell"
    
    var name: String? {
        didSet {
            textLabel?.text = name
        }
    }
    
    var address: String? {
        didSet {
            detailTextLabel?.text = address
        }
    }
}
