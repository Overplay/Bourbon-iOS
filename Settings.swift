//
//  Settings.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 7/13/16.
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

import Foundation


// NSUserDefaults settings are wrapped here for cleanliness

class Settings {
    
    let userDefaults = UserDefaults.standard

    static let sharedInstance = Settings()

    // MARK App Modes
    
    var isDevelopmentMode: Bool {
        get {
            return userDefaults.bool(forKey: "devMode")
        }
        set {
            userDefaults.set(newValue, forKey: "devMode")
        }
    }
    
    var appleReviewMode: Bool {
        get {
            return userDefaults.bool(forKey: "appleReviewMode")
        }
        set {
            userDefaults.set(newValue, forKey: "appleReviewMode")
        }
    }
    
    // MARK Asahi Cloud Services
    
    var ourglassCloudBase: String {
        get {
            return userDefaults.string(forKey: "asahiBase") ?? "whoopsie"
        }
        set {
            userDefaults.set(newValue, forKey: "asahiBase")
        }
    }
    
    var ourglassCloudScheme: String {
        get {
            return userDefaults.string(forKey: "asahiScheme") ?? "http://"
        }
        set {
            userDefaults.set(newValue, forKey: "asahiScheme")
        }
    }
    
    var ourglassCloudBaseUrl: String {
        return ourglassCloudScheme + ourglassCloudBase
    }
    
    // MARK: OG Discovery Protocol
    
    var udpDiscoveryPort: UInt16 {
        return 9091
    }
    
    
    // MARK: User info
    
    var userId: String? {
        get {
            return userDefaults.string(forKey: "userId")
        }
        set {
            userDefaults.set(newValue, forKey: "userId")
        }
    }
    
    var userFirstName: String? {
        get {
            return userDefaults.string(forKey: "userFirstName")
        }
        set {
            userDefaults.set(newValue, forKey: "userFirstName")
        }
    }
    
    var userLastName: String? {
        get {
            return userDefaults.string(forKey: "userLastName")
        }
        set {
            userDefaults.set(newValue, forKey: "userLastName")
        }
    }

    
    var userEmail: String? {
        get {
            return userDefaults.string(forKey: "userEmail")
        }
        set {
            userDefaults.set(newValue, forKey: "userEmail")
        }
    }

    var userAsahiJWT: String? {
        get {
            return userDefaults.string(forKey: "userAsahiJWT")
        }
        set {
            userDefaults.set(newValue, forKey: "userAsahiJWT")
        }
    }
    
    var userAsahiJWTExpiry: Int {
        get {
            return userDefaults.integer(forKey: "userAsahiJWTExpiry")
        }
        set {
            userDefaults.set(newValue, forKey: "userAsahiJWTExpiry")
        }
    }

    
    // TODO: This absolutely should never be used plaintext after release!!!
    var userPassword: String? {
        get {
            return userDefaults.string(forKey: "userPwd")
        }
        set {
            userDefaults.set(newValue, forKey: "userPwd")
        }
    }

    var isRegistered: Bool {
        get {
            return userDefaults.bool(forKey: "isRegistered")
        }
        set {
            userDefaults.set(newValue, forKey: "isRegistered")
        }
    }
    
    var allowAccountCreation: Bool {
        get {
            return userDefaults.bool(forKey: "allowAccountCreation")
        }
        set {
            userDefaults.set(newValue, forKey: "allowAccountCreation")
        }
    }
    
    var appOpened: Bool {
        get {
            return userDefaults.bool(forKey: "appOpened")
        }
        set {
            userDefaults.set(newValue, forKey: "appOpened")
        }
    }
    
    var alwaysShowIntro: Bool {
        get {
            return userDefaults.bool(forKey: "alwaysShowIntro")
        }
        set {
            userDefaults.set(newValue, forKey: "alwaysShowIntro")
        }
    }


    // MARK:Defaults
    
    func registerDefaults() {
        
        userDefaults.register(defaults: [
            
            "devMode" :  true,
            "alwaysShowIntro": false,
            "allowAccountCreation": true,
            "asahiScheme" : "http://",
            "asahiBase" : "107.170.209.248",
            "appleReviewMode" : false,
            "isRegistered" : false
            
        ])
    }

}
