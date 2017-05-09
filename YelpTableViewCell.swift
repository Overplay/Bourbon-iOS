//
//  YelpTableViewCell.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/5/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class YelpTableViewCell: UITableViewCell {
    static let identifier = "YelpTableViewCell"
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var venueImage: UIImageView!
}
