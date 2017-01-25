//
//  RequestRouter.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 9/30/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

// NO LONGER USED FOR ALAMOFIRE 4!!!

//import Foundation
//import Alamofire
//import PromiseKit
//import SwiftyJSON
//
//enum RequestRouter: URLRequestConvertible {
//    
//    static let baseURLString: String = Settings.sharedInstance.ourglassCloudBaseUrl
//    
//    case getToken()
//    case register([String: AnyObject])
//    case login([String: AnyObject])
//    case changePwd([String: AnyObject])
//    case getVenues()
//    case getAuthStatus()
//    case logout()
//    case changeAccountInfo([String: AnyObject], String)
//    case inviteNewUser([String: AnyObject])
//    
//    var URLRequest: NSMutableURLRequest {
//        var method: HTTPMethod {
//            switch self {
//            case .getToken, .getVenues, .getAuthStatus, .logout:
//                return .get
//            case .register, .login, .changePwd, .inviteNewUser:
//                return .post
//            case .changeAccountInfo:
//                return .put
//            }
//        }
//        
//        let params: ([String: AnyObject]?) = {
//            switch self {
//            case .getToken, .getVenues, .getAuthStatus, .logout:
//                return (nil)
//            case .register(let newUser):
//                return (newUser)
//            case .login(let user):
//                return (user)
//            case .changePwd(let newPass):
//                return (newPass)
//            case .changeAccountInfo(let info, _):
//                return (info)
//            case .inviteNewUser(let email):
//                return (email)
//            }
//        }()
//        
//        let url: URL = {
//            let relativePath: String?
//            switch self {
//            case .getToken:
//                relativePath = "/user/jwt"
//            case .register:
//                relativePath = "/auth/addUser"
//            case .login:
//                relativePath = "/auth/login"
//            case .changePwd:
//                relativePath = "/auth/changePwd"
//            case .getVenues:
//                relativePath = "/api/v1/venue"
//            case .getAuthStatus:
//                relativePath = "/auth/status"
//            case .logout:
//                relativePath = "/auth/logoutPage"
//            case .changeAccountInfo(_, let userId):
//                relativePath = "api/v1/user/\(userId)"
//            case .inviteNewUser:
//                relativePath = "/user/inviteNewUser"
//            }
//            
//            var URL = Foundation.URL(string: RequestRouter.baseURLString)!
//            if let relativePath = relativePath {
//                URL = URL.URLByAppendingPathComponent(relativePath)
//            }
//            
//            return URL
//        }()
//        
//        let URLRequest = NSMutableURLRequest(url: url)
//        
//        if let _ = Settings.sharedInstance.userAsahiJWT {
//            URLRequest.setValue("Bearer: \(Settings.sharedInstance.userAsahiJWT)", forHTTPHeaderField: "Authorization")
//        }
//        
//        let encoding: Alamofire.ParameterEncoding
//        
//        switch self {
//        case .getToken, .getVenues, .getAuthStatus, .logout:
//            encoding = Alamofire.ParameterEncoding.URL
//        case .register, .login, .changePwd, .changeAccountInfo, .inviteNewUser:
//            encoding = Alamofire.ParameterEncoding.JSON
//        }
//        
//        let (encodedRequest, _) = encoding.encode(URLRequest as! URLRequestConvertible, with: params)
//        
//        encodedRequest.HTTPMethod = method.rawValue
//        
//        return encodedRequest
//    }
//}

