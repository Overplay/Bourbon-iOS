//
//  VenueBaseViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 4/24/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import SwiftyJSON

class VenueBaseViewController: UIViewController {
    
    var venues = [OGVenue]()
    
    func processVenues( _ inboundVenueJson: JSON ){
        
        guard let venueArray = inboundVenueJson.array else {
            log.debug("No venues found!")
            return
        }
        
        self.venues = [OGVenue]()
        
        for venue in venueArray {
            
            let address = venue["address"]
            let geolocation = venue["geolocation"]
            
            guard let name = venue["name"].string else {
                log.debug("found a venue with no name, skipping")
                continue
            }
            guard let uuid = venue["uuid"].string else {
                log.debug("found a venue with no uuid, skipping")
                continue
            }
            
            // Address components compiled into one human readable string
            guard let street = address["street"].string, let city = address["city"].string,
                let state = address["state"].string, let zip = address["zip"].string else {
                    log.debug("found a venue with incomplete address, skipping")
                    continue
            }
            let addressString = String(format: "%@, %@, %@, %@", street, city, state, zip)
            
            guard let latitude = geolocation["latitude"].double, let longitude = geolocation["longitude"].double else {
                log.debug("found a venue with no geolocation, skipping")
                continue
            }
            
            self.venues.append(OGVenue(name: name, address: addressString, latitude: latitude, longitude: longitude, uuid: uuid))
        }
        
    }
}
