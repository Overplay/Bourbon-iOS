//
//  Network.swift
//  Absinthe-iOS-X8
//
//  Created by Mitchell Kahn on 1/16/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import Foundation
import SystemConfiguration
import NetUtils

class Network {
    
    static func getWiFiInterface() -> Interface? {
        
        let interfaces = Interface.allInterfaces()
        for iface in interfaces {
            if iface.name == "en0" && iface.family == .ipv4 {
                return iface
            }
        }
        
        return nil
    }
    
    static func currentSSIDs() -> [String] {
        
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        return interfaceNames.flatMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            return ssid
        }
    }

    static func wifiSSID() -> String? {
        
        return currentSSIDs().first
        
    }
    
    
    // Get IP address of OPIE from data
    static func getIPAddressFromData(address: NSData) -> String? {
        var ipAddress : String?
        var sa = sockaddr()
        
        address.getBytes(&sa, length: MemoryLayout<sockaddr>.size)
        
        if Int32(sa.sa_family) == AF_INET {
            var ip4 = sockaddr_in()
            address.getBytes(&ip4, length: MemoryLayout<sockaddr_in>.size)
            ipAddress = String(format: "%s", inet_ntoa(ip4.sin_addr))
        }
        
        return ipAddress
    }

    
    
}
