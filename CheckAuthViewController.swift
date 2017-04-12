//
//  CheckAuthViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/24/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PromiseKit

enum AuthError: Error {
    case JWTExpired
    case noJWTFound
}

class CheckAuthViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkUserStatus()
            .then{ response -> Void in
                self.performSegue(withIdentifier: "fromCheckAuthToMainTabs", sender: nil)
            }
        
            .catch{ err -> Void in
                self.performSegue(withIdentifier: "fromCheckAuthToLR", sender: nil)
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    // TODO: unless we want to do a call to checkJWT, this doesn't need to be a promise
    func checkUserStatus() -> Promise<Bool> {
        
        return Promise<Bool> { resolve, reject in
            
            if let expiry = Settings.sharedInstance.userBelliniJWTExpiry,
                let _ = Settings.sharedInstance.userBelliniJWT {

                if Date() > Date(timeIntervalSince1970: expiry) { // JWT has expired
                    reject(AuthError.JWTExpired)
                } else {
                    resolve(true)
                }
                
            } else {
                reject(AuthError.noJWTFound)
            }
            
            /*
             Asahi.sharedInstance.checkAuthStatus()
                
                .then{ response -> Void in
                    log.debug("Successfully checked auth")
                    if let first = response["firstName"].string {
                        Settings.sharedInstance.userFirstName = first
                    }
                    
                    if let last = response["lastName"].string {
                        Settings.sharedInstance.userLastName = last
                    }
                    
                    if let email = response["auth"]["email"].string {
                        Settings.sharedInstance.userEmail = email
                    }
                    
                    if let id = response["id"].string {
                        Settings.sharedInstance.userId = id
                    }
                    
                    resolve(true)
                }
                
                .catch{ err -> Void in
                    log.debug("not authorized")
                    reject(err)
            }
            */
            
        }
    }

}
