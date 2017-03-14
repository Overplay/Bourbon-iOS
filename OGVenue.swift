//
//  OGVenue.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/10/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class OGVenue {
    
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var uuid: String
    
    init(name: String, address: String, latitude: Double, longitude: Double, uuid: String) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
    }
    
    init() {
        self.name = ""
        self.address = ""
        self.latitude = -1
        self.longitude = -1
        self.uuid = ""
    }
    
    
    func description() -> String {
        return "name: \(self.name) " +
            "address: \(self.address) " +
            "uuid: \(self.uuid) "
    }
}
