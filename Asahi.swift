//
//  Asahi.swift
//  Absinthe-iOS
//
//  Created by Noah on 7/19/16.
//  Edits by Mitch Sept 2016
//  Completely re-written for Swift 3/PromiseKit in Jan 2017
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

//  This is the interface to the Ourglass Cloud Server aka Asahi aka Applejack


import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

enum AsahiError: Error {
    case authFailure
    case tokenInvalid
    case malformedJson
}

open class Asahi: NSObject {
    
    let q = DispatchQueue.global()

    static let sharedInstance = Asahi()
    
    var _postNotification = false
    
    
    func createApiEndpoint(_ endpoint: String) -> String {
        return Settings.sharedInstance.ourglassCloudBaseUrl + ":" + Settings.sharedInstance.ourglassBasePort + endpoint
    }
    
    func createApiEndpointWithPort(_ endpoint: String, port: String) -> String {
        return Settings.sharedInstance.ourglassCloudBaseUrl + ":" + port + endpoint
    }
    
    func doJsonTransaction( _ endpoint: String, data: Dictionary<String, Any>, method: HTTPMethod ) -> Promise<JSON> {
        return Promise { fulfill, reject in
            Alamofire.request(endpoint, method: method, parameters: data,
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
                                        log.debug("resource not allowed for this user")
                                        reject(AsahiError.authFailure)
                                    }
                                    .catch { error -> Void in
                                        log.debug("token invalid")
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
    
    // Promisified JSON Poster
    func postJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: data, method: .post)
    }
    
    // Promisified JSON Putter
    func putJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: data, method: .put)
    }
    
    // Promisified JSON Getter
    func getJson(_ endpoint: String, parameters: [String: Any] = [:]) -> Promise<JSON> {
        return doJsonTransaction(endpoint, data: parameters, method: .get)
    }

    
    // TODO: sign in with Facebook (use "type": "facebook" on login and register)
    func register(_ email: String, password: String, user: Dictionary<String, Any>) -> Promise<String> {
            
            let params: Dictionary<String, Any> = [
                "email":email,
                "password":password,
                "user": user,
                "type":"local"]

            return postJson(createApiEndpoint("/auth/addUser"), data: params as Dictionary<String, AnyObject>)
                .then{ _ -> Promise<String> in
                    Settings.sharedInstance.userEmail = email
                    return self.getToken()
                    
        }
    }
    
    func login(_ email: String, password: String) -> Promise<String> {
        
        return loginOnly(email, password: password)
            .then{ _ -> Promise<String> in
                return self.getToken()
        }
    }

    // TODO: MAK This should be replaced with a proper JSON login endpoint (see above)
    func loginOnly(_ email: String, password: String) -> Promise<Bool> {
        
        let params: Dictionary<String, Any> = [
            "email":email,
            "password":password,
            "type":"local"]
        
        return postJson(createApiEndpoint("/auth/login"), data: params)
            .then{ json -> Bool in
                Settings.sharedInstance.userEmail = email
                ASNotification.asahiLoggedIn.issue()
                return true
                
        }
    }
    
    
    func getToken() -> Promise<String> {
        return getJson(createApiEndpoint("/user/jwt"))
            .then{ json -> String in
                Settings.sharedInstance.userBelliniJWT = (json["token"].stringValue)
                Settings.sharedInstance.userBelliniJWTExpiry = json["expires"].doubleValue/1000.0
                return Settings.sharedInstance.userBelliniJWT!
        }
    }

    func changePassword(_ email: String, newPassword: String) -> Promise<Bool> {
        let params = ["email": email, "newpass": newPassword]
        return postJson(createApiEndpoint("/auth/changePwd"), data: params)
            .then{ json -> Bool in
                return true
        }
    }
    
    func getVenues() -> Promise<JSON> {
        return getJson(createApiEndpoint("/venue/all"))
    }
    
    func getDevices(_ venueUUID: String) -> Promise<JSON> {
        return getJson(createApiEndpointWithPort("/venue/devices?atVenueUUID=" + venueUUID, port: "2001"))
    }
    
    func checkJWT() -> Promise<JSON> {
        // cannot use same get() as everyone else or we might end up in a loop on 403 handling
        return Promise { fulfill, reject in
            Alamofire.request(createApiEndpoint("/user/checkjwt"), method: .get,
                              headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ])
                .validate()
                .responseJSON() { response in
                    switch response.result {
                        
                    case .success(let dict):
                        fulfill(JSON(dict))
                        
                    case .failure(let error):
                        reject(error)
                    }
            }
        }
    }
    
    func changeAccountInfo(_ firstName: String, lastName: String, email: String, userId: String) -> Promise<JSON> {
        let params: Dictionary<String, Any> = ["email": email, "firstName": firstName, "lastName": lastName]
        return putJson(createApiEndpoint("/user/\(userId)"), data: params)
    }
    
    // TODO: is there more we need to do here?
    func logout() {
        Settings.sharedInstance.userBelliniJWT = nil
        Settings.sharedInstance.userBelliniJWTExpiry = nil
        Settings.sharedInstance.userId = nil
    }
    
    func inviteNewUser(_ email: String) -> Promise<JSON> {
        let params = ["email": email]
        return postJson(createApiEndpoint("/user/inviteNewUser"), data: params)
    }
    
    func getUserVenues() -> Promise<JSON> {
        return getJson(createApiEndpoint("/venue/myvenues"))
    }
    
    func findByRegCode(_ regCode: String) -> Promise<JSON> {
        let params = ["regcode": regCode]
        return getJson(createApiEndpointWithPort("/ogdevice/findByRegCode", port: "2001"), parameters: params)
    }
    
    func changeDeviceName(_ udid: String, name: String) -> Promise<String> {
        let params = ["deviceUDID": udid, "name": name]
        return postJson(createApiEndpointWithPort("/ogdevice/changeName", port: "2001"), data: params)
            .then { _ -> String in
                return udid
        }
    }
    
    func associate(deviceUdid: String, withVenueUuid: String) -> Promise<JSON> {
        let params = ["deviceUDID": deviceUdid, "venueUUID": withVenueUuid]
        return postJson(createApiEndpointWithPort("/ogdevice/associateWithVenue", port: "2001"), data: params)
    }
    
    func yelpSearch(location: String, term: String) -> Promise<JSON> {
        let params = ["location": location, "term": term]
        return getJson(createApiEndpoint("/venue/yelpSearch"), parameters: params)
    }
    
    func yelpSearch(latitude: Double, longitude: Double, term: String) -> Promise<JSON> {
        let params = ["latitude": latitude, "longitude": longitude, "term": term] as [String : Any]
        return getJson(createApiEndpoint("/venue/yelpSearch"), parameters: params)
    }
    
    
        // Auto sign in on app startup, but this is if we're saving the username/password in plain text so this is only temporary
        // Eventually move to JWTs so we can uncomment this when that is setup and migrate over to using those
        //    override init() {
        //        super.init()
        //        let email = NSUserDefaults.standardUserDefaults().valueForKey("Email") as? String
        //        let password = NSUserDefaults.standardUserDefaults().valueForKey("Password") as? String
        //        if email != nil && password != nil {
        //            _postNotification = true
        //            self.login(email!, password: password!)
        //        }
        //    }

        
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

