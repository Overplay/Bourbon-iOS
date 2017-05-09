//
//  LoginBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/21/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class LoginBaseViewController: RegSceneBaseViewController {
    
    @IBOutlet var pwdLabel: UILabel!
    @IBOutlet var pwdTextField: UITextField!
    @IBOutlet var pwdGoodCheck: UIImageView!
    @IBOutlet var nextButton: UIButton!
    
    @IBAction func showPwdPressed(_ sender: UIButton) {
        pwdTextField.isSecureTextEntry = !pwdTextField.isSecureTextEntry
        if pwdTextField.isSecureTextEntry {
            sender.setTitle("SHOW", for: .normal)
        } else {
            sender.setTitle("HIDE", for: .normal)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        pwdTextField.useCustomBottomBorder()

        pwdLabel.alpha = 0
        nextButton.alpha = 0
        pwdGoodCheck.alpha = 0
        
        UIView.animate(withDuration: 0.65, animations: {
            self.pwdLabel.alpha = 1
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkFields), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)

    }
    

    func checkFields(_ notification: Notification) {
        if let pwd = pwdTextField.text {
            fade(pwdGoodCheck, onCondition: pwd.isValidPwd())
            fade(nextButton, onCondition: pwd.isValidPwd())
        }
    }
    
    func login(_ email: String, pwd: String){
        Asahi.sharedInstance.login(email, password: pwd)
            .then{ response -> Void in
                HUD.flash(.labeledSuccess(title: "Logged In!", subtitle: nil ))
            }
            .catch{ err in
                self.recoverFromLoginFailure()
                
        }
    }
    
    func loginWithSegue(_ email: String, pwd: String, segueId: String){
        
        Asahi.sharedInstance.login(email, password: pwd)
            .then{ response -> Void in
                HUD.flash(.labeledSuccess(title: "Logged In!", subtitle: nil ))
                log.debug("OK, let's do this!")
                self.performSegue(withIdentifier: segueId, sender: nil)
            }
            .catch{ err in
                self.recoverFromLoginFailure()
                
        }
        
    }
    
    
    // This is normally handled in the child class
    func recoverFromLoginFailure(){
        log.debug("Login failed")
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
