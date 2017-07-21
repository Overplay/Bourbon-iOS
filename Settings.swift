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

    
    // MARK Asahi Cloud Services
    
    var hasValidJwt: Bool {
        get {
            if self.userBelliniJWTExpiry != nil && self.userBelliniJWT != nil {
                if Date() < Date(timeIntervalSince1970: Settings.sharedInstance.userBelliniJWTExpiry! - 86400.0) { // JWT has expired or will expire in the next day
                    return true
                }
            }
            return false
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
    
    func getJwt() -> String {
        return userBelliniJWT ?? ""
    }
    
    var userBelliniJWTExpiry: Double? {
        get {
            return userDefaults.double(forKey: "userBelliniJWTExpiry")
        }
        set {
            userDefaults.set(newValue, forKey: "userBelliniJWTExpiry")
        }
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
    
    // New stuff to allow to point to dev server(s)
    
    var useDevServer: Bool {
        get {
            return userDefaults.bool(forKey: "useDevServer")
        }
        set {
            userDefaults.set(newValue, forKey: "useDevServer")
        }
        
    }
    
    var userIsDeveloper: Bool {
        get {
            return userDefaults.bool(forKey: "userIsDev")
        }
        set {
            userDefaults.set(newValue, forKey: "userIsDev")
        }
        
    }



    // MARK:Defaults
    
    func registerDefaults() {
        
        userDefaults.register(defaults: [
            
            "alwaysShowIntro": false,
            "allowAccountCreation": true,
            "appOpened": false
            
        ])
    }

}
