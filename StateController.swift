//
//  StateController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/1/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

class StateController {
    
    static let sharedInstance = StateController()
    
    private(set) var venues = [OGVenue]()
    
    private init() {}
    
    func findAndProcessVenues() -> Promise<JSON> {
        return Promise { fulfill, reject in
            Asahi.sharedInstance.getVenues()
                .then { response -> Void in
                    self.processVenues(response)
                    fulfill(response)
                }
                .catch { err -> Void  in
                    reject(err)
            }
        }
    }
    
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
            
            guard let street = address["street"].string, let city = address["city"].string,
                let state = address["state"].string, let zip = address["zip"].string else {
                    log.debug("found a venue with incomplete address, skipping")
                    continue
            }
            
            guard let latitude = geolocation["latitude"].double, let longitude = geolocation["longitude"].double else {
                log.debug("found a venue with no geolocation, skipping")
                continue
            }
            
            self.venues.append(OGVenue(name: name, street: street, city: city, state: state, zip: zip, latitude: latitude, longitude: longitude, uuid: uuid))
        }
    }
    
    // TODO: save venues with NSCoder things (https://www.smashingmagazine.com/2016/05/better-architecture-for-ios-apps-model-view-controller-pattern/)
}
