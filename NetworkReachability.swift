//
//  NetworkReachability.swift
//  Absinthe-iOS-X8
//
//  Created by Alyssa Torres on 2/17/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import Alamofire

class NetworkReachability {
    static let sharedInstance = NetworkReachability()

    let manager: NetworkReachabilityManager = NetworkReachabilityManager(host: "www.apple.com")!
    
    func startListening() {
        manager.listener = { status in
            log.info("Network status changed: \(status)")
            ASNotification.networkChanged.issue()
        }
        manager.startListening()
    }
    
    func stopListening() {
        manager.stopListening()
    }
}
