//
//  YelpVenue.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/5/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import SwiftyJSON

enum YelpError: Error {
    case badJson
}

class YelpVenue {
    
    var name: String
    var imageUrl: String
    var distance: String
    var yelpId: String
    
    var address1: String
    var address2: String
    var city: String
    var state: String
    var zip: String
    var country: String
    
    var latitude: Double
    var longitude: Double
    
    var displayAddress: [String]
    
    var address: String {
        return displayAddress.joined(separator: ", ")
    }
    
    init(_ venueJson: JSON) throws {
        let location = venueJson["location"]
        let coords = venueJson["coordinates"]
        
        guard let name = venueJson["name"].string, let imageUrl = venueJson["image_url"].string,
            let yelpId = venueJson["id"].string, let displayAddress = location["display_address"].array,
            let address1 = location["address1"].string,
            let city = location["city"].string, let state = location["state"].string,
            let zip = location["zip_code"].string, let country = location["country"].string,
            let lat = coords["latitude"].double, let lng = coords["longitude"].double
        else {
            throw YelpError.badJson
        }
        
        // Handle fields that are not required and can be set to a default
        if let dist = venueJson["distance"].double {
            self.distance = String(format: "%.1f km", dist / 1000.0)
        } else {
            self.distance = ""
        }
        
        if let address2 = location["address2"].string {
            self.address2 = address2
        } else {
            self.address2 = ""
        }
        
        self.name = name
        self.imageUrl = imageUrl
        self.yelpId = yelpId
        self.displayAddress = displayAddress.map({$0.stringValue})
        self.address1 = address1
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.latitude = lat
        self.longitude = lng
    }
    
    
    func description() -> String {
        return "name: \(self.name) " +
            "address: \(self.address) "
    }
}
