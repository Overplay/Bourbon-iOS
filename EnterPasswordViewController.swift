//
//  EnterPasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

// A lot of this VCs functionality is in the Base VC
class EnterPasswordViewController: LoginBaseViewController {
    
    let segueId = "fromPasswordToMainTabs"

    @IBAction func nextPressed(_ sender: UIButton) {
        
        HUD.show(.labeledProgress(title: "Creating Account", subtitle: "Please Wait"))
        
        Asahi.sharedInstance.register(Settings.sharedInstance.userEmail!,
                                      password: pwdTextField.text!,
                                      user: [ "firstName": Settings.sharedInstance.userFirstName!,
                                            "lastName": Settings.sharedInstance.userLastName! ])
            .then{ response -> Void in
                HUD.flash(.labeledSuccess(title: "All Set!", subtitle: "Welcome to Ourglass"), delay: 1.0, completion: { (_) in
                    self.performSegue(withIdentifier: self.segueId, sender: nil)
                })
            }
            .catch{ err -> Void in
                // On the off chance an account already exists
                self.loginWithSegue(Settings.sharedInstance.userEmail!, pwd: self.pwdTextField.text!, segueId: self.segueId)
        }
        
    }
    
    override func recoverFromLoginFailure() {
        super.recoverFromLoginFailure()
        recoverFromRegFailure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pwdTextField.useCustomBottomBorder()
    }
    
    func recoverFromRegFailure(){
        
        HUD.hide()
        
        let alertController = UIAlertController(title: "Uh Oh", message: "There was a problem registering. Do you already have an account with that email?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }

}
