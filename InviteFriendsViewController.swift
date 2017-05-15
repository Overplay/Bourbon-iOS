//
//  InviteFriendsViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/25/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PromiseKit
import PKHUD

class InviteFriendsViewController: AccountBaseViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var inviteButton: UIButton!
    
    var emailDelegate: CustomTextFieldDelegate?
    
    @IBAction func invite(_ sender: AnyObject) {
        
        guard let e = email.text, isValidEmail(e) else {
            emailDelegate?.textFieldDidEndEditing(email)
            return
        }
            
        Asahi.sharedInstance.inviteNewUser(e)
            
            .then{ response -> Void in
                log.debug("invitation sent")
                HUD.flash(.success, delay: 1.0)
            }
            
            .catch{ error -> Void in
                log.debug(error)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailDelegate = CustomTextFieldDelegate(email, isValid: isValidEmail)
    }
    
    func isValidEmail(_ string: String?) -> Bool {
        if let str = string {
            return str.isValidEmail()
        }
        return false
    }
}
