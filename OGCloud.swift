//
//  OGCloud.swift
//  Bourbon-iOS
//
//  Created by Mitchell Kahn on 5/26/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

// Replacement for Asahi singleton which was having problems with SSL for some reason

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

/// Error class used with Asahi
///
/// - authFailure: the user is not authorized to perform the action
/// - tokenInvalid: the current token is invalid
/// - malformedJson: the response JSON was not as expected
enum OGCloudError: Error {
    case authFailure
    case tokenInvalid
    case malformedJson
}

open class OGCloud: NSObject {
    
    static let sharedInstance = OGCloud()
    let q = DispatchQueue.global()
    let initGroup = DispatchGroup()

    static let belliniCore = "https://cloud.ourglass.tv/"
    static let belliniDM = "https://cloud-dm.ourglass.tv/"
    
    override init() {
        super.init()
        // throwaway call to set the Sails cookie
        // put in DispatchGroup so we don't make any other calls until this completes
        self.initGroup.enter()
        self.checkJWT().always {
            self.initGroup.leave()
        }
    }

    // Promisified JSON getter
    func getJson(_ endpoint: String, parameters: [String: AnyObject] = [:]) -> Promise<JSON> {
        
        return firstly {
            Alamofire.request( endpoint, method: .get,
                               parameters: parameters,
                               headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ] )
                .validate()
                .responseJSON()
            }
            .then( on:q){ value  in
                JSON(value)
        }
        
    }
    
    // Promisified JSON Poster
    func postJson( _ endpoint: String, data: Dictionary<String, AnyObject> ) -> Promise<JSON> {
        
        return firstly{
            Alamofire.request(endpoint, method: .post,
                              parameters: data,
                              headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ]  )
                .validate()  //Checks for non-200 response
                .responseJSON()
            }
            .then( on:q){ value  in
                JSON(value)
        }
    }
    
    // Promisified JSON Putter
    func putJson( _ endpoint: String, data: Dictionary<String, AnyObject> ) -> Promise<JSON> {
        
        return firstly{
            Alamofire.request(endpoint, method: .put,
                              parameters: data,
                              headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ]  )
                .validate()  //Checks for non-200 response
                .responseJSON()
            }
            .then( on:q){ value  in
                JSON(value)
        }
    }

    
    // MARK: VENUES
    
    // Gets all venues.
    //
    // - Returns: a promise resolving in the response JSON which contains the venues
    func getVenues() -> Promise<JSON> {
        return getJson( OGCloud.belliniCore + "venue/all" )
    }
    
    /// Gets the venues associated with the current user.
    ///
    /// - Returns: a promise resolving in the venues JSON
    func getUserVenues() -> Promise<JSON> {
        return getJson(  OGCloud.belliniCore + "venue/myvenues" )
    }
    
    /// Creates a new venue.
    ///
    /// - Parameter venue: the venue to create
    /// - Returns: a promise resolving in the new venue's uuid
    func addVenue(venue: OGVenue) -> Promise<String> {
        
        let params: [String: Any] = [
            "name": venue.name,
            "address": [
                "street": venue.street,
                "street2": venue.street2,
                "city": venue.city,
                "state": venue.state,
                "zip": venue.zip
            ],
            "geolocation": [
                "latitude": venue.latitude,
                "longitude": venue.longitude
            ],
            "yelpId": venue.yelpId
        ]
        
        return postJson( OGCloud.belliniCore + "venue", data: params as Dictionary<String, AnyObject>)
            .then { response -> String in
                guard let uuid = response["uuid"].string else {
                    throw OGCloudError.malformedJson
                }
                ASNotification.asahiAddedVenue.issue()
                return uuid
        }
    }
 
    
    // MARK: USER LOGIN/CREATE

    func login(_ email: String, password: String) -> Promise<JSON> {
        let loginData = ["email": email, "password": password, "type":"local" ]
        return postJson( OGCloud.belliniCore + "auth/login", data: loginData as Dictionary<String, AnyObject>)
            .then{ response -> JSON in
                Settings.sharedInstance.userEmail = email
                ASNotification.asahiLoggedIn.issue()
                return response
        }
    }
    
    func loginAndGetToken(_ email: String, password: String) -> Promise<String> {
        
        return login(email, password: password).then { _ -> Promise<String> in
            return self.getToken()
            }
            .then { token -> Promise<String> in
                return self.checkSession().then {_ -> Promise<String> in
                    return token
                }
        }
    }
    
    func extractUserInfo(_ response: JSON ){
        Settings.sharedInstance.userId = response["id"].string
        Settings.sharedInstance.userFirstName = response["firstName"].string
        Settings.sharedInstance.userLastName = response["lastName"].string
        Settings.sharedInstance.userEmail = response["email"].string
    }
    
    // Checks the current user's JWT and stores user info if it finds it.
    //
    // - Returns: a promise resolving in the response JSON
    func checkJWT() -> Promise<JSON> {
        return getJson(OGCloud.belliniCore + "user/checkjwt")
            .then { response -> JSON in
                self.extractUserInfo(response)
                return response
            }
    }
    
    /// Gets a JWT.
    ///
    /// - Returns: a promise resolving in the JWT
    func getToken() -> Promise<String> {
        return getJson( OGCloud.belliniCore + "user/jwt")
            .then{ response -> String in
                
                guard let token = response["token"].string,
                    let expires = response["expires"].double else {
                        throw OGCloudError.malformedJson
                }
                Settings.sharedInstance.userBelliniJWT = token
                Settings.sharedInstance.userBelliniJWTExpiry = expires / 1000.0
                return token
        }
    }

    
    // Checks the current user's session and stores user info if it finds it.
    //
    // - Returns: a promise resolving in the response JSON
    func checkSession() -> Promise<JSON> {
        return getJson( OGCloud.belliniCore + "user/checksession")
            .then { response -> JSON in
                self.extractUserInfo(response)
                return response
        }
    }

    /// Changes account information of a user.
    ///
    /// - Parameters:
    ///   - firstName: new first name
    ///   - lastName: new last name
    ///   - email: new email
    ///   - userId: the user's ID
    /// - Returns: a promise resolving in the response JSON
    func changeAccountInfo(_ firstName: String, lastName: String, email: String, userId: String) -> Promise<JSON> {
        let params: Dictionary<String, Any> = ["email": email, "firstName": firstName, "lastName": lastName]
        return putJson(  OGCloud.belliniCore + "user/\(userId)", data: params as Dictionary<String, AnyObject>)
    }
    
    /// Changes the password of the user.
    ///
    /// - Parameters:
    ///   - email: user's email
    ///   - newPassword: new password
    /// - Returns: a promise resolving in `true` on success
    func changePassword(_ email: String, newPassword: String) -> Promise<Bool> {
        let params = ["email": email, "newpass": newPassword]
        return postJson( OGCloud.belliniCore + "auth/changePwd", data: params as Dictionary<String, AnyObject>)
            .then{ json -> Bool in
                return true
        }
    }
    
    /// Logs out of OurGlass by removing stored information.
    func logout() -> Promise<JSON>{
        return postJson(OGCloud.belliniCore + "auth/logout", data: Dictionary<String, AnyObject>())
        .then{ json -> JSON in
            Settings.sharedInstance.userBelliniJWT = nil
            Settings.sharedInstance.userBelliniJWTExpiry = nil
            Settings.sharedInstance.userId = nil
            return json
        }
        
    }
    
    /// Invites someone to OurGlass via email.
    ///
    /// - Parameter email: invitee's email
    /// - Returns: a promise resolving in the response JSON
    func inviteNewUser(_ email: String) -> Promise<JSON> {
        let params = ["email": email]
        //return postJson(createApiEndpoint("/user/inviteNewUser"), data: params)
        return postJson( OGCloud.belliniCore + "user/inviteNewUser",
                              data: params as Dictionary<String, AnyObject>)
    }

    
    // Registers a new user, gets a token, and sets `Settings` user variables.
    //
    // - Parameters:
    //   - email: user's email
    //   - password: user's password
    //   - user: user's first and last name
    // - Returns: a promise resolving in the new user's JWT
    func register(_ email: String, password: String, user: Dictionary<String, Any>)
        -> Promise<String> {
            
            let params: Dictionary<String, Any> = [
                "email":email,
                "password":password,
                "user": user,
                "type":"local"]
            
            return postJson( OGCloud.belliniCore + "auth/addUser",
                            data: params as Dictionary<String, AnyObject>)
                
                .then{ _ -> Promise<String> in
                    Settings.sharedInstance.userEmail = email
                    return self.getToken()
                }.then { token -> Promise<String> in
                    return self.checkSession().then {_ -> Promise<String> in
                        return token
                    }
            }
    }
    
    
    // MARK: BELLINI DEVICE MANAGER METHODS
    
    /// Finds a device by its registration code.
    ///
    /// - Parameter regCode: registration code
    /// - Returns: a promise resolving in the device JSON
    func findByRegCode(_ regCode: String) -> Promise<JSON> {
        let params = ["regcode": regCode]
        return getJson( OGCloud.belliniDM + "ogdevice/findByRegCode",
                        parameters: params as [String : AnyObject])
    }
    
    /// Changes the name of the device associated with `udid`.
    ///
    /// - Parameters:
    ///   - udid: device UDID
    ///   - name: name to give the device
    /// - Returns: a promise resolving in the device's `udid`
    func changeDeviceName(_ udid: String, name: String) -> Promise<String> {
        let params = ["deviceUDID": udid, "name": name]
        return postJson( OGCloud.belliniDM + "ogdevice/changeName",
                         data: params as Dictionary<String, AnyObject>)
            .then { _ -> String in
                ASNotification.asahiUpdatedDevice.issue()
                return udid
        }
    }
    
    /// Associates a device with a venue.
    ///
    /// - Parameters:
    ///   - deviceUdid: device UDID
    ///   - withVenueUuid: venue UUID
    /// - Returns: a promise resolving in the JSON response from the call
    func associate(deviceUdid: String, withVenueUuid: String) -> Promise<JSON> {
        let params = ["deviceUDID": deviceUdid, "venueUUID": withVenueUuid]
        return postJson( OGCloud.belliniDM + "ogdevice/associateWithVenue",
                          data: params as Dictionary<String, AnyObject>)
            .then { response -> JSON in
                ASNotification.asahiUpdatedDevice.issue()
                return response
        }
    }
    
    /// Gets the devices associated with a venue.
    ///
    /// - Parameter venueUUID: venue's UUID
    /// - Returns: a promise resolving in the response JSON
    func getDevices(_ venueUUID: String) -> Promise<JSON> {
        return getJson( OGCloud.belliniDM + "venue/devices?atVenueUUID=" + venueUUID )
    }

    // MARK: YELP
    
    /// Performs a Yelp search.
    ///
    /// - Parameters:
    ///   - location: location of the search
    ///   - term: search term
    /// - Returns: a promise resolving in a JSON array of the results
    func yelpSearch(location: String, term: String) -> Promise<JSON> {
        let params = ["location": location, "term": term]
        return getJson(  OGCloud.belliniCore + "venue/yelpSearch",
                         parameters: params as Dictionary<String, AnyObject>)
    }
    
    /// Performs a Yelp search.
    ///
    /// - Parameters:
    ///   - latitude: latitude of search location
    ///   - longitude: longitude of search location
    ///   - term: search term
    /// - Returns: a promise resolving in a JSON array of the results
    func yelpSearch(latitude: Double, longitude: Double, term: String) -> Promise<JSON> {
        let params = ["latitude": latitude, "longitude": longitude, "term": term] as [String : Any]
        return getJson( OGCloud.belliniCore + "venue/yelpSearch",
                        parameters: params as Dictionary<String, AnyObject>)
    }



}
