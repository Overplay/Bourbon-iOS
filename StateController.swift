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
    
    private(set) var allVenues = [OGVenue]()
    
    private(set) var myVenues = [OGVenue]()
    
    private init() {}
    
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
    
    func processVenues( _ inboundVenueJson: JSON ) -> [OGVenue] {
        
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
            venues.append(OGVenue(name: name, street: street, city: city, state: state, zip: zip, latitude: latitude, longitude: longitude, uuid: uuid))
        }
        
        venues.sort{ $0.name < $1.name }
        return venues
    }
    
    // TODO: save state with NSCoder things, example: https://www.smashingmagazine.com/2016/05/better-architecture-for-ios-apps-model-view-controller-pattern/
}
