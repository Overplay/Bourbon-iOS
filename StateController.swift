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

/// Provides the current state of the application.
class StateController {
    
    static let sharedInstance = StateController()
    
    /// All venues.
    private(set) var allVenues = [OGVenue]()
    
    /// Venues associated with the current user.
    private(set) var myVenues = [OGVenue]()
    
    private init() {}
    
    /// Finds all venues and updates the current state.
    ///
    /// - Returns: a promise resolving in `true` on success
    func findAllVenues() -> Promise<Bool> {
        return Promise { fulfill, reject in
            
            Asahi.sharedInstance.getVenues()
                
                .then { response -> Void in
                    self.allVenues = self.processVenues(response)
                    fulfill(true)
                }
                .catch { err -> Void  in
                    reject(err)
            }
        }
    }
    
    /// Finds the venues associated with the current user.
    ///
    /// - Returns: a promise resolving in `true` on success
    func findMyVenues() -> Promise<Bool> {
        return Promise { fulfill, reject in
            
            Asahi.sharedInstance.getUserVenues()
                
                .then { response -> Void in
                    
                    if let owned = response["owned"].array, let managed = response["managed"].array {
                        self.myVenues = self.processVenues(JSON(owned + managed))
                        fulfill(true)
                    } else {
                        reject(AsahiError.malformedJson)
                    }
                }
                .catch { err -> Void  in
                    reject(err)
            }
        }
    }
    
    /// Processes the venues JSON as `OGVenue` objects and sorts the venues alphabetically.
    ///
    /// - Parameter inboundVenueJson: venue JSON
    /// - Returns: an array of the resulting `OGVenue` objects
    private func processVenues( _ inboundVenueJson: JSON ) -> [OGVenue] {
        
        var venues = [OGVenue]()
        
        guard let venueArray = inboundVenueJson.array else {
            log.debug("No venues found!")
            return venues
        }
        
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
            let ogVenue = OGVenue(name: name, street: street, city: city, state: state,
                                  zip: zip, latitude: latitude, longitude: longitude,
                                  uuid: uuid)
            
            // check for optional values
            if let street2 = address["street2"].string {
                ogVenue.street2 = street2
            }
            if let yelpId = venue["yelpId"].string {
                ogVenue.yelpId = yelpId
            }
            
            venues.append(ogVenue)
        }
        
        venues.sort{ $0.name < $1.name }
        return venues
    }
    
    // TODO: save state with NSCoder things, example: https://www.smashingmagazine.com/2016/05/better-architecture-for-ios-apps-model-view-controller-pattern/
}
