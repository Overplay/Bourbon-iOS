//
//  Settings.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 7/13/16.
//  Copyright © 2016 Ourglass TV. All rights reserved.
//

import Foundation


/// `NSUserDefaults` settings are wrapped here for cleanliness.
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
            return userDefaults.string(forKey: "ourglassBase") ?? "whoopsie"
        }
        set {
            userDefaults.set(newValue, forKey: "ourglassBase")
        }
    }
    
    var ourglassCloudScheme: String {
        get {
            return userDefaults.string(forKey: "ourglassScheme") ?? "http://"
        }
        set {
            userDefaults.set(newValue, forKey: "ourglassScheme")
        }
    }
    
    var ourglassCloudBaseUrl: String {
        return ourglassCloudScheme + ourglassCloudBase
    }
    
    var ourglassBasePort: String {
        get {
            return userDefaults.string(forKey: "ourglassBasePort") ?? "2000"
        }
        set {
            userDefaults.set(newValue, forKey: "ourglassBasePort")
        }
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

    var userBelliniJWT: String? {
        get {
            return userDefaults.string(forKey: "userBelliniJWT")
        }
        set {
            userDefaults.set(newValue, forKey: "userBelliniJWT")
        }
    }
    
    var userBelliniJWTExpiry: Double? {
        get {
            return userDefaults.double(forKey: "userBelliniJWTExpiry")
        }
        set {
            userDefaults.set(newValue, forKey: "userBelliniJWTExpiry")
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
            "ourglassScheme" : "http://",
            "ourglassBase" : "138.68.230.239",
            "ourglassBasePort": "2000",
            "appleReviewMode" : false,
            "isRegistered" : false
            
        ])
    }

}
