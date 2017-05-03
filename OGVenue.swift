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
    var street: String
    var city: String
    var state: String
    var zip: String
    var latitude: Double
    var longitude: Double
    var uuid: String
    
    var address: String {
        return String(format: "%@, %@, %@, %@", street, city, state, zip)
    }
    
    init(name: String, street:String, city: String, state: String, zip: String, latitude: Double, longitude: Double, uuid: String) {
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
    }
    
    
    func description() -> String {
        return "name: \(self.name) " +
            "address: \(self.address) " +
            "uuid: \(self.uuid) "
    }
}
