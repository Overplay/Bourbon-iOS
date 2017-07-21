//
//  OGDevice.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import SwiftyJSON

class OGDevice {
    
    var name: String = ""
    var atVenueUUID: String = ""
    var udid: String = ""
    var stationName: String = ""
    var isActive: Bool = false
    var lastContact: Date?
    
//    init() {
//        self.name = ""
//        self.atVenueUUID = ""
//        self.udid = ""
//    }
    
    init(name: String, atVenueUUID: String, udid: String) {
        self.name = name
        self.atVenueUUID = atVenueUUID
        self.udid = udid
    }
    
    init(inboundJson: JSON){
        self.name = inboundJson["name"].stringValue
        self.udid = inboundJson["deviceUDID"].stringValue
        self.atVenueUUID = inboundJson["atVenueUUID"].stringValue
        self.stationName = inboundJson["currentProgram"]["networkName"].stringValue
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.lastContact = formatter.date(from: inboundJson["lastContact"].stringValue)
        let interval = -Double(lastContact?.timeIntervalSinceNow ?? 10000.0)
        self.isActive = interval < 300.0 // five minutes ago
        
    }
    
    func getUrl() -> String {
        return OGCloud.sharedInstance.belliniDM +
            "/blueline/control?deviceUDID=\(self.udid)&jwt=\(Settings.sharedInstance.getJwt())"
    }
    
}
