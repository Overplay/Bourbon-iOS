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
    case noEmailError
    case noPasswordError
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

    func checkUserStatus() -> Promise<Bool> {
        
        return Promise<Bool> { resolve, reject in
            
            if let email = Settings.sharedInstance.userEmail {
                if let pwd = Settings.sharedInstance.userPassword {
                    
                    Asahi.sharedInstance.login(email, password: pwd)
                        
                        .then{ response -> Void in
                            
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
                                    reject(err)
                            }
                        }
                        
                        .catch{ err -> Void in
                            reject(err)
                    }
                    
                } else {
                    reject(AuthError.noPasswordError)
                }
            } else {
                reject(AuthError.noEmailError)
            }
        }
    }

}
