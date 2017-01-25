//
//  ABNetworking.swift
//  Absinthe-iOS
//
//  Interface to AmstelBright APIs
//
//  Created by Mitchell Kahn on 8/31/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class ABNetworking {
    
    var ipAddress: String = ""
    var useHttps = false
    let q = DispatchQueue.global()
    let token = "FAKETOKEN$$"

    
    var apiPath: String  {
        return ( self.useHttps ? "https://" : "http://" ) + self.ipAddress + "api/"
    }
    
    enum ABErrors: Error {
        case badUrl
        case notAuthorized
        case weird
    }
    
    // Promisified JSON getter
    func getJson(_ endpoint: String, parameters: [String: Any] = [:]) -> Promise<JSON> {
        
        return firstly {
            Alamofire.request( endpoint, method: .get, parameters: parameters )
                .validate()
                .responseJSON()
            }
            .then( on:q){ value  in
                JSON(value)
        }
        
    }
    
    func postOrPutJson( _ endpoint: String, data: Dictionary<String, Any>, method: HTTPMethod ) -> Promise<JSON> {
        return firstly{
            Alamofire.request(endpoint, method: method, parameters: data,
                              headers: [ "X-AB-Token" : self.token ])
                .validate()  //Checks for non-200 response
                .responseJSON()
            }
            .then( on:q){ value  in
                JSON(value)
        }
        
    }
    
    // Promisified JSON Poster
    func postJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return postOrPutJson(endpoint, data: data, method: .post)
    }
    
    // Promisified JSON Putter
    func putJson( _ endpoint: String, data: Dictionary<String, Any> ) -> Promise<JSON> {
        return postOrPutJson(endpoint, data: data, method: .put)
    }

    
    
    func getSystemInfo() -> Promise<JSON> {
        
        return getJson(apiPath+"/system/device")
        
    }
    
}
