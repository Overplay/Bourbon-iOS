//
//  EnterEmailViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class EnterEmailViewController: RegSceneBaseViewController {

    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var emailGoodCheck: UIImageView!
    
    @IBOutlet var nextButton: UIButton!
    
    
    var emailOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.useCustomBottomBorder()
        
        emailLabel.alpha = 0
        nextButton.alpha = 0
        
        emailGoodCheck.alpha = 0
        
        UIView.animate(withDuration: 0.65, animations: {
            self.emailLabel.alpha = 1
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkEmail), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("Delegate: should return")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        log.debug("Delegate: did end editing")
        //checkNames()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    
    func checkEmail(_ notification: Notification){
        if let email = emailTextField.text {
            fade(emailGoodCheck, onCondition: email.isValidEmail())
            fade(nextButton, onCondition: email.isValidEmail())
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Settings.sharedInstance.userEmail = emailTextField.text
    }
}
