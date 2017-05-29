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
    
    /// Venues associated with the current user (owned and managed).
    private(set) var myVenues = [VenueCollection]()
    
    /// Venues owned by the current user.
    private(set) var ownedVenues = [OGVenue]()
    
    /// Venues managed by the current user.
    private(set) var managedVenues = [OGVenue]()
    
    private init() {
        
        let nc = NotificationCenter.default
        
        nc.addObserver(
            forName: NSNotification.Name(rawValue:ASNotification.asahiAddedVenue.rawValue),
            object: nil, queue: nil) { _ in
                _ = self.findAllVenues()
                _ = self.findMyVenues()
        }
        
        // TODO I'm not loving how this is done.
        nc.addObserver(
            forName: NSNotification.Name(rawValue:ASNotification.networkReachable.rawValue),
            object: nil, queue: nil) { _ in
                _ = self.findAllVenues()
                _ = self.findMyVenues()
        }
    }
    
    // TODO these promises below need simplifcation
    
    /// Finds all venues and updates the current state.
    ///
    /// - Returns: a promise resolving in `true` on success
    func findAllVenues() -> Promise<Bool> {
        return Promise { fulfill, reject in
            
            OGCloud.sharedInstance.getVenues()
                
                .then { response -> Void in
                    self.allVenues = self.processVenues(response)
                    ASNotification.allVenuesUpdated.issue()
                    fulfill(true)
                }
                .catch { err -> Void  in
                    // TODO this is not the right way to handle this. 403 should be causght in the OGCloud code. Fix later.
                    ASNotification.error403.issue()
                    reject(err)
            }
        }
    }
    
    /// Finds the venues associated with the current user.
    ///
    /// - Returns: a promise resolving in `true` on success
    func findMyVenues() -> Promise<Bool> {
        return Promise { fulfill, reject in
            
            OGCloud.sharedInstance.getUserVenues()
                
                .then { response -> Void in
                    
                    //if let owned = response["owned"], let managed = response["managed"] {
                        self.ownedVenues = self.processVenues(response["owned"])
                        self.managedVenues = self.processVenues(response["managed"])
                        self.myVenues = [VenueCollection("Owned", self.ownedVenues),
                                         VenueCollection("Managed", self.managedVenues)]
                        ASNotification.myVenuesUpdated.issue()
                        fulfill(true)
                    //} else {
                    //    reject(OGCloudError.malformedJson)
                    //}
                }
                .catch { err -> Void  in
                    // TODO this is not the right way to handle this. 403 should be causght in the OGCloud code. Fix later.
                    ASNotification.error403.issue()
                    reject(err)            }
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
                log.debug("found venue named \(name) with no uuid, skipping")
                continue
            }
            guard let street = address["street"].string, let city = address["city"].string,
                let state = address["state"].string, let zip = address["zip"].string else {
                    log.debug("found venue named \(name) with incomplete address, skipping")
                    continue
            }
            
            let latitude = geolocation["latitude"].doubleValue
            let longitude = geolocation["longitude"].doubleValue
            
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

/// Helper class to represent venues that are of a certain type.
class VenueCollection {
    var label: String
    var venues: [OGVenue]
    
    init(_ label: String, _ venues: [OGVenue]) {
        self.label = label
        self.venues = venues
    }
}
