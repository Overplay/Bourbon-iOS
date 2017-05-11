//
//  ASNotification.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Mods by mitch 9/2016
//  Copyright © 2016 App Delegates. All rights reserved.
//


import Foundation

enum ASNotification: String {
    
    case newOg
    case droppedOg
    case ogSocketError
    case asahiLoggedIn
    case networkChanged
    
    func issue(userInfo: Dictionary<String, Any>? = nil){
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.rawValue),
                                        object: nil, userInfo: userInfo)
    }
    
}
