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
    @IBOutlet weak var emailGoodCheck: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    
    @IBAction func invite(_ sender: AnyObject) {
        
        guard let e = self.email.text
            else {
                showAlert("Oops!", message: "The email you put in is not valid.")
                return
        }
        
        if e.isValidEmail() {
            
            Asahi.sharedInstance.inviteNewUser(e)
            
                .then{ response -> Void in
                    log.debug("invitation sent")
                    HUD.flash(.success, delay: 1.0)
                }
            
                .catch{ error -> Void in
                    log.debug(error)
                }
        }
        
        else {
            showAlert("Oops!", message: "The email you put in is not valid.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.email.useCustomBottomBorder()
        
        self.emailGoodCheck.alpha = 0
        self.inviteButton.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkEmail), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    func checkEmail() {
        
        if let email = self.email.text {
            
            if email.isValidEmail() {
                fadeIn(self.emailGoodCheck)
                fadeIn(self.inviteButton)
            }
            
            if !email.isValidEmail() {
                fadeOut(self.emailGoodCheck)
                fadeOut(self.inviteButton)
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
