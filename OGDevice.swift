//
//  OGDevice.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class OGDevice {
    
    var name: String
    var atVenueUUID: String
    var udid: String
    
    init() {
        self.name = ""
        self.atVenueUUID = ""
        self.udid = ""
    }
    
    init(name: String, atVenueUUID: String, udid: String) {
        self.name = name
        self.atVenueUUID = atVenueUUID
        self.udid = udid
    }
    
    func getUrl() -> String {
        return "\(Settings.sharedInstance.ourglassCloudBaseUrl):2001/blueline/control/?deviceUDID=\(self.udid)"
    }
    
}
