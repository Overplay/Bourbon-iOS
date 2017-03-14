//
//  DeviceCell.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class DeviceCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    func swiped(_ sender: UISwipeGestureRecognizer){
        log.debug("device swiped")
    }
    
    override func awakeFromNib() {
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        sgr.direction = .left
        
    }
    
}
