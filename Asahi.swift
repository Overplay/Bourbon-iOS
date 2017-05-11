//
//  Asahi.swift
//  Absinthe-iOS
//
//  Created by Noah on 7/19/16.
//  Edits by Mitch Sept 2016
//  Completely re-written for Swift 3/PromiseKit in Jan 2017
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

/// Error class used with Asahi
///
/// - authFailure: the user is not authorized to perform the action
/// - tokenInvalid: the current token is invalid
/// - malformedJson: the response JSON was not as expected
enum AsahiError: Error {
    case authFailure
    case tokenInvalid
    case malformedJson
}

/// The interface to the Ourglass Cloud Server aka Asahi aka Applejack
open class Asahi: NSObject {
    
    let q = DispatchQueue.global()

    static let sharedInstance = Asahi()
    
    var _postNotification = false
    
    override init() {
        super.init()
        // throwaway call to set the Sails cookie
        _ = self.checkJWT()
    }
    
    /// Creates an API endpoint with the default base URL and default 
    /// port stored in Settings.
    ///
    /// - Parameter endpoint: the endpoint to append to the base
    /// - Returns: the complete API endpoint
    func createApiEndpoint(_ endpoint: String) -> String {
        return Settings.sharedInstance.ourglassCloudBaseUrl + ":" + Settings.sharedInstance.ourglassBasePort + endpoint
    }
    
    /// Creates an API endpoing with the default base URL stored in 
    /// Settings and the provided port.
    ///
    /// - Parameters:
    ///   - endpoint: endpoint to append to the base
    ///   - port: port
    /// - Returns: the complete API endpoint
    func createApiEndpoint(_ endpoint: String, withPort port: String) -> String {
        return Settings.sharedInstance.ourglassCloudBaseUrl + ":" + port + endpoint
    }
    
    /// Makes an HTTP request with Alamofire to get the JSON contents
    /// of the response.
    ///
    /// - Parameters:
    ///   - endpoint: the URL
    ///   - data: parameters to send
    ///   - method: the HTTP method to use
    ///   - encoding: the parameter encoding
    /// - Returns: a promise resolving in the JSON contents of the response
    func doJsonTransaction( _ endpoint: String,
                            data: Dictionary<String, Any>,
                            method: HTTPMethod,
                            encoding: ParameterEncoding) -> Promise<JSON> {
        
        return Promise { fulfill, reject in
            Alamofire.request(endpoint,
                              method: method,
                              parameters: data,
                              encoding: encoding,
                              headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ])
                .validate()
                .responseJSON() { response in
                    
                    switch response.result {
                        
                    case .success(let dict):
                        fulfill(JSON(dict))
                        
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            
                            if statusCode == 403 {
                                Asahi.sharedInstance.checkJWT()
                                    .then { response -> Void in
                                        log.debug("\(statusCode): resource not allowed for this user")
                                        reject(AsahiError.authFailure)
                                    }
                                    .catch { error -> Void in
                                        log.debug("\(statusCode): token invalid")
                                        reject(AsahiError.tokenInvalid)
                                }
                            } else {
                                reject(error)
                            }
                        } else {
                            reject(error)
                        }
                    }
            }
        }
    }
    
    /// Promisified JSON Poster.
    func postJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: data, method: .post,
                                 encoding: JSONEncoding.default)
    }
    
    /// Promisified JSON Putter.
    func putJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: data, method: .put,
                                 encoding: JSONEncoding.default)
    }
    
    /// Promisified JSON Getter.
    func getJson(_ endpoint: String, parameters: [String: Any] = [:]) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: parameters, method: .get,
                                 encoding: URLEncoding.default)
    }

    /// Registers a new user, sets `Settings` user variables, and gets a JWT.
    ///
    /// - Parameters:
    ///   - email: user's email
    ///   - password: user's password
    ///   - user: user's first and last name
    /// - Returns: a promise resolving in the new user's JWT
    func register(_ email: String, password: String, user: Dictionary<String, Any>)
        -> Promise<String> {
            
            let params: Dictionary<String, Any> = [
                "email":email,
                "password":password,
                "user": user,
                "type":"local"]

            return postJson(createApiEndpoint("/auth/addUser"),
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
    
    /// Logs in to OurGlass, sets `Settings` user variables, and gets a JWT.
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    /// - Returns: a promise resolving in the user's JWT
    func login(_ email: String, password: String) -> Promise<String> {
        
        return loginOnly(email, password: password).then { _ -> Promise<String> in
                return self.getToken()
        }.then { token -> Promise<String> in
            return self.checkSession().then {_ -> Promise<String> in
                return token
            }
        }
    }
    
    // TODO: sign in with Facebook (use "type": "facebook" on login and register)

    /// Logs in to Ourglass without getting a JWT.
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    /// - Returns: a promise resolving in `true` on success
    func loginOnly(_ email: String, password: String) -> Promise<Bool> {
        // TODO: MAK This should be replaced with a proper JSON login endpoint (see above)
        let params: Dictionary<String, Any> = [
            "email":email,
            "password":password,
            "type":"local"]
        
        return postJson(createApiEndpoint("/auth/login"), data: params)
            .then{ response -> Bool in
                Settings.sharedInstance.userEmail = email
                ASNotification.asahiLoggedIn.issue()
                return true
                
        }
    }
    
    /// Gets a JWT.
    ///
    /// - Returns: a promise resolving in the JWT
    func getToken() -> Promise<String> {
        return getJson(createApiEndpoint("/user/jwt"))
            .then{ response -> String in
                
                guard let token = response["token"].string,
                    let expires = response["expires"].double else {
                        throw AsahiError.malformedJson
                }
                Settings.sharedInstance.userBelliniJWT = token
                Settings.sharedInstance.userBelliniJWTExpiry = expires / 1000.0
                return token
        }
    }
    
    /// Checks the current user's session and stores user info if it finds it.
    ///
    /// - Returns: a promise resolving in the response JSON
    func checkSession() -> Promise<JSON> {
        return getJson(createApiEndpoint("/user/checksession"))
            .then { response -> JSON in
                
                guard let id = response["id"].string,
                    let first = response["firstName"].string,
                    let last = response["lastName"].string,
                    let email = response["email"].string else {
                        log.error("unable to get user info from /user/checksession")
                        return response
                }
                Settings.sharedInstance.userId = id
                Settings.sharedInstance.userFirstName = first
                Settings.sharedInstance.userLastName = last
                Settings.sharedInstance.userEmail = email
                
                return response
        }
    }
    
    /// Gets all venues.
    ///
    /// - Returns: a promise resolving in the response JSON which contains the venues
    func getVenues() -> Promise<JSON> {
        return getJson(createApiEndpoint("/venue/all"))
    }
    
    /// Gets the devices associated with a venue.
    ///
    /// - Parameter venueUUID: venue's UUID
    /// - Returns: a promise resolving in the response JSON
    func getDevices(_ venueUUID: String) -> Promise<JSON> {
        return getJson(createApiEndpoint("/venue/devices?atVenueUUID=" + venueUUID,
                                         withPort: "2001"))
    }
    
    /// Checks the user's current JWT to see if it is still valid.
    ///
    /// - Returns: a promise resolving in the response JSON
    func checkJWT() -> Promise<JSON> {
        // cannot use same getJson() as everyone else or we might end up in a loop on 403 error handling
        return Promise { fulfill, reject in
            Alamofire.request(createApiEndpoint("/user/checkjwt"),
                              method: .get,
                              headers: ["Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ])
                .validate()
                .responseJSON() { response in
                    switch response.result {
                        
                    case .success(let dict):
                        let response = JSON(dict)
                        
                        guard let id = response["id"].string,
                            let first = response["firstName"].string,
                            let last = response["lastName"].string,
                            let email = response["email"].string else {
                                log.error("unable to get user info from /user/checkjwt")
                                fulfill(response)
                                return
                        }
                        
                        Settings.sharedInstance.userId = id
                        Settings.sharedInstance.userFirstName = first
                        Settings.sharedInstance.userLastName = last
                        Settings.sharedInstance.userEmail = email
                        fulfill(response)
                        
                    case .failure(let error):
                        reject(error)
                    }
            }
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
        return putJson(createApiEndpoint("/user/\(userId)"), data: params)
    }
    
    /// Changes the password of the user.
    ///
    /// - Parameters:
    ///   - email: user's email
    ///   - newPassword: new password
    /// - Returns: a promise resolving in `true` on success
    func changePassword(_ email: String, newPassword: String) -> Promise<Bool> {
        let params = ["email": email, "newpass": newPassword]
        return postJson(createApiEndpoint("/auth/changePwd"), data: params)
            .then{ json -> Bool in
                return true
        }
    }
    
    /// Logs out of OurGlass by removing stored information.
    func logout() { // TODO: is there more we need to do here?
        Settings.sharedInstance.userBelliniJWT = nil
        Settings.sharedInstance.userBelliniJWTExpiry = nil
        Settings.sharedInstance.userId = nil
    }
    
    /// Invites someone to OurGlass via email.
    ///
    /// - Parameter email: invitee's email
    /// - Returns: a promise resolving in the response JSON
    func inviteNewUser(_ email: String) -> Promise<JSON> {
        let params = ["email": email]
        return postJson(createApiEndpoint("/user/inviteNewUser"), data: params)
    }
    
    /// Gets the venues associated with the current user.
    ///
    /// - Returns: a promise resolving in the venues JSON
    func getUserVenues() -> Promise<JSON> {
        return getJson(createApiEndpoint("/venue/myvenues"))
    }
    
    /// Finds a device by its registration code.
    ///
    /// - Parameter regCode: registration code
    /// - Returns: a promise resolving in the device JSON
    func findByRegCode(_ regCode: String) -> Promise<JSON> {
        let params = ["regcode": regCode]
        return getJson(createApiEndpoint("/ogdevice/findByRegCode", withPort: "2001"),
                       parameters: params)
    }
    
    /// Changes the name of the device associated with `udid`.
    ///
    /// - Parameters:
    ///   - udid: device UDID
    ///   - name: name to give the device
    /// - Returns: a promise resolving in the device's `udid`
    func changeDeviceName(_ udid: String, name: String) -> Promise<String> {
        let params = ["deviceUDID": udid, "name": name]
        return postJson(createApiEndpoint("/ogdevice/changeName", withPort: "2001"),
                        data: params)
            .then { _ -> String in
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
        return postJson(createApiEndpoint("/ogdevice/associateWithVenue", withPort: "2001"),
                        data: params)
    }
    
    /// Performs a Yelp search provided a location term.
    ///
    /// - Parameters:
    ///   - location: location of the search
    ///   - term: search term
    /// - Returns: a promise resolving in a JSON array of the results
    func yelpSearch(location: String, term: String) -> Promise<JSON> {
        let params = ["location": location, "term": term]
        return getJson(createApiEndpoint("/venue/yelpSearch"), parameters: params)
    }
    
    /// Performs a Yelp search provided a latitude and longitude.
    ///
    /// - Parameters:
    ///   - latitude: latitude of search location
    ///   - longitude: longitude of search location
    ///   - term: search term
    /// - Returns: a promise resolving in a JSON array of the results
    func yelpSearch(latitude: Double, longitude: Double, term: String) -> Promise<JSON> {
        let params = ["latitude": latitude, "longitude": longitude, "term": term] as [String : Any]
        return getJson(createApiEndpoint("/venue/yelpSearch"), parameters: params)
    }
    
    /// POSTs the venue data to create a new venue.
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
        
        return postJson(createApiEndpoint("/venue"), data: params)
            .then { response -> String in
                guard let uuid = response["uuid"].string else {
                    throw AsahiError.malformedJson
                }
                return uuid
        }
    }

        
    // MARK Test Methods
    
    //TODO these are probably shite with all the casts to NSError no longer needed
    func testRegistration(){
        
        // Create unique email
        let email = "absinthe-\(Date().timeIntervalSince1970)@test.com"
        
        register(email, password: "yah00die", user: [ "firstName":"Dick", "lastName":"Yahoodie"])
            .then { response -> Void in
                log.debug("Well, I got a response regging: \(response)")
            }
            .catch { ( err: Error ) -> Void in
                log.debug("hmm, that sucks")
                let nse = err as NSError
                log.error("\(nse.localizedDescription)")
        }
    }

    // MARK Assumes "absinthetest@ourglass.tv/ab5inth3" exists in the system
    func testLogin(){
        
        login("absinthetest@ourglass.tv", password: "ab5inth3")
            .then { response -> Void in
                log.debug("Well, I got a response logging in: \(response)")
            }
            .catch { ( err: Error ) -> Void in
                log.debug("hmm, that sucks")
                let nse = err as NSError
                log.error("\(nse.localizedDescription)")
        }

    }
    
    func testGetVenues(){
        
        getVenues()
            .then { response -> Void in
                log.debug("Well, I got a response logging in: \(response)")
            }
            .catch { ( err: Error ) -> Void in
                log.debug("hmm, that sucks")
                let nse = err as NSError
                log.error("\(nse.localizedDescription)")
        }

    }
    
}

