//
//  LoginOrRegViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class LoginOrRegViewController: RegSceneBaseViewController {
    

    @IBOutlet var ogLogoView: UIImageView!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var loginWithFBButton: UIButton!
    @IBOutlet var logoToTop: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeToTop: NSLayoutConstraint!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "fromLRToLogin", sender: nil)
    }
    
    @IBAction func signupPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "fromLRToEnterName", sender: nil)
    }
    
    @IBAction func resetPwd(_ sender: Any) {
        // "https://cloud.ourglass.tv/login"
        UIApplication.shared.openURL(URL(string: "https://cloud.ourglass.tv/login")!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Move the check for logged in somewhere else so reg scene doesn't flash
        
        // For now, log in using Settings, then check Auth status
        
        let welcomeRestPosition = welcomeToTop.constant
        self.welcomeToTop.constant = -200
        
        self.loginButton.alpha = 0
        self.signUpButton.alpha = 0
        self.orLabel.alpha = 0
        
        self.view.layoutIfNeeded()

        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.14, initialSpringVelocity: 3.0, options: .curveLinear, animations: {
            self.welcomeToTop.constant = welcomeRestPosition
            self.view.layoutIfNeeded()
            }, completion: { _ in
                
                // Bring in buttons
                UIView.animate(withDuration: 0.35, animations: { 
                    self.loginButton.alpha = 1
                    }, completion: { _ in
                        
                        if Settings.sharedInstance.allowAccountCreation {
                            
                            UIView.animate(withDuration: 0.35, animations: {
                                self.orLabel.alpha = 1
                                
                            }, completion: { _ in
                                UIView.animate(withDuration: 0.35, animations: {
                                    self.signUpButton.alpha = 1
                                })
                            })
                        }
                })
        })
    }


}
