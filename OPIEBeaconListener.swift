//
//  OPIEBeaconListener.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/31/16.
//  Mods by Noah August 2016
//  Mods by Mitch Sept 2016
//  Swift 3 conversion by Mitch 1/2017
//  Copyright © 2016 Ourglass. All rights reserved.
//

import CocoaAsyncSocket
import SwiftyJSON
import NetUtils

class OPIEBeaconListener: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let sharedInstance = OPIEBeaconListener()
    
    let BROADCAST_HOST = "255.255.255.255"
    let PORT = Settings.sharedInstance.udpDiscoveryPort
    
    // time between pseudo upnp broadcast
    let broadcastInterval: Double = 10
    
    let maxTTL = 6
    
    // TODO: [mak] are their situations where this could fail (!)?
    
    var interface = Network.getWiFiInterface()
    
    // For identifying different UDP packets sent to different hosts or whatever
    // This doesn't really matter for our usecase
    let TAG = 1
    
    var socket: GCDAsyncUdpSocket!
    let nc = NotificationCenter.default
    
    // Array of Ourglass Players
    var opies = [OPIE]()
    
    func startListening() {
        
        opies = [OPIE]()
                
        self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)

        do {
            try self.socket.bind(toPort: PORT, interface: "en0")
        } catch {
            log.error("ERROR: OPIE socket failed to bind to port \(self.PORT)")
            ASNotification.ogSocketError.issue()
            return
        }
        
        do {
            try self.socket.enableBroadcast(true)
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to enable broadcast.")
            ASNotification.ogSocketError.issue()
            return
        }
        
        do {
            try self.socket.beginReceiving()
        } catch {
            self.socket.close()
            log.error("ERROR: OPIE socket failed to begin receiving.")
            ASNotification.ogSocketError.issue()
            return
        }
        
        Timer.scheduledTimer(timeInterval: broadcastInterval, target: self, selector: #selector(handleTimerFire), userInfo: nil, repeats: true)
    }
    
    func stopListening() {
        self.socket.close()
    }
    
    func handleTimerFire() {
        broadcastPacket()
        decrementTTL()
    }
    
    func broadcastPacket() {
        
        log.info("Broadcasting pseudo upnp discovery packet...")
        
        do {
            // JSON object to broadcast to the LAN
            let jsonPacket = JSON([
                //"ip": netInfo["ip"]!,
                //TODO FIX FIX
                "ip": interface?.address ?? "missing",
                "action": "discover",
                "time": Date().timeIntervalSince1970
                ])
            
            try self.socket.send(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT, withTimeout: -1, tag: TAG)
            
            // On the simulator, toss a second packet to port 9092 in case we're running local ogUdpSimulator
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                try self.socket.send(jsonPacket.rawData(), toHost: BROADCAST_HOST, port: PORT+1, withTimeout: -1, tag: TAG)
            #endif
        
        } catch {
            log.error("ERROR: OPIE socket failed to send packet.")
            ASNotification.ogSocketError.issue()
        }
    }
    
    func processOPIE(_ receivedOp: OPIE) {
        
        for op in self.opies {
            
            if op.ipAddress == receivedOp.ipAddress {
                op.systemName = receivedOp.systemName
                op.location = receivedOp.location
                op.ttl = maxTTL
                ASNotification.newOg.issue(userInfo: ["OPIE":op])
                return
            }
            
        }
        
        receivedOp.ttl = maxTTL
        self.opies.append(receivedOp)
        ASNotification.newOg.issue(userInfo: ["OPIE": receivedOp])
       
    }
    
    func decrementTTL() {
        
        var current = [OPIE]()
        var drop = false
        
        for op in self.opies {
            
            op.ttl -= 1
            
            if op.ttl <= 0 {
                drop = true
            }
            
            else {
                current.append(op)
            }
        }
        
        self.opies = current
        if drop == true {
            ASNotification.droppedOg.issue()
        }
    }
    
    // These funcs are marked as @objc so that this swift class can act as a delegate
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        log.info("Sent packet into nothingness... hoping for response.")
    }
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        
        log.error("ERROR: OPIE socket failed to send packet.\(error)")
        ASNotification.ogSocketError.issue()
        
    }
    
    @objc func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let ipAddress = Network.getIPAddressFromData(address: address as NSData)
        
        guard ipAddress != nil else {
            log.error("Got nil IP address as source of UDP packet, bailing!")
            return
        }
        
        guard ipAddress != interface?.address else {
            log.debug("Got my own address as source of UDP packet, skipping!")
            return
        }
        
        let receivedOp = OPIE()
        
        let ogJSON = JSON(data)
        
        guard ogJSON["randomFactoid"].stringValue != "" else {
            return
        }
        
        receivedOp.systemName = ogJSON["name"].string ?? "Ourglass System"
        receivedOp.location = ogJSON["locationWithinVenue"].string ?? "No Location Set"
        receivedOp.venue = ogJSON["venue"].stringValue
        
        receivedOp.ipAddress = ipAddress!
        
        processOPIE(receivedOp)

    }
    
    
}
