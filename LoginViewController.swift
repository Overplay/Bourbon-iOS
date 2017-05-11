//
//  LoginViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class LoginViewController: LoginBaseViewController {
    
    let segueId = "fromLoginToMainTabs"
    
    @IBOutlet var emailTextField: UITextField!    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet var emailGoodCheck: UIImageView!
    
    var emailTextFieldDelegate: CustomTextFieldDelegate?
    
    @IBAction func goPressed(_ sender: UIButton){
        loginWithSegue(emailTextField.text!, pwd: pwdTextField.text!, segueId: segueId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextFieldDelegate = CustomTextFieldDelegate(emailTextField,
                                                         isValid: isValidEmail,
                                                         errorLabel: emailErrorLabel)
        
        UIView.animate(withDuration: 0.35, delay: 0.65, options: .curveEaseInOut, animations: { 
            self.emailLabel.alpha = CGFloat(1.0)
        }, completion: nil)
        
        emailGoodCheck.alpha = 0

    }
    
    override func checkFields(_ notification: Notification) {
        guard let email = emailTextField.text, let pwd = pwdTextField.text else {
            return
        }

        fade(emailGoodCheck, onCondition: email.isValidEmail())
        fade(pwdGoodCheck, onCondition: pwd.isValidPwd())
        fade(nextButton, onCondition: email.isValidEmail() && pwd.isValidPwd())
    }
    
    override func recoverFromLoginFailure() {
        super.recoverFromLoginFailure()
        HUD.hide()
        
        let alertController = UIAlertController(title: "Uh Oh", message: "There was a problem logging in.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
