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
    @IBOutlet var emailGoodCheck: UIImageView!
    
    var emailOK = false;
    
    @IBAction func goPressed(_ sender: UIButton){
        loginWithSegue(emailTextField.text!, pwd: pwdTextField.text!, segueId: segueId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 0.35, delay: 0.65, options: .curveEaseInOut, animations: { 
            self.emailLabel.alpha = CGFloat(1.0)
        }, completion: nil)
        
        emailGoodCheck.alpha = 0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func checkFields(_ notification: Notification) {
        super.checkFields(notification)
        
        if let email = emailTextField.text {
            
            if email.isValidEmail() && emailGoodCheck.alpha == 0 {
                fadeIn(emailGoodCheck)
                fadeIn(nextButton)
                emailOK = true
            }
            
            if !email.isValidEmail() {
                fadeOut(emailGoodCheck)
                fadeOut(nextButton)
                emailOK = false
                
            }
        }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
