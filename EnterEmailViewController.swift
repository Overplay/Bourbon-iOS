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
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet var nextButton: UIButton!
    
    var emailOK = false
    
    var emailDelegate: CustomTextFieldDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailDelegate = CustomTextFieldDelegate(emailTextField, isValid: self.isValidEmail,
                                                errorLabel: emailErrorLabel)
        
        emailLabel.alpha = 0
        nextButton.alpha = 0
        
        emailGoodCheck.alpha = 0
        
        UIView.animate(withDuration: 0.65, animations: {
            self.emailLabel.alpha = 1
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkEmail), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
    }
    
    func checkEmail(_ notification: Notification) {
        if let email = emailTextField.text {
            fade(emailGoodCheck, onCondition: email.isValidEmail())
            fade(nextButton, onCondition: email.isValidEmail())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Settings.sharedInstance.userEmail = emailTextField.text
    }
}
