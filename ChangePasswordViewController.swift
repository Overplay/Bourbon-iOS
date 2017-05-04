//
//  ChangePasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/17/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class ChangePasswordViewController: AccountBaseViewController {
    
    var email: String?
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var repeatNewPassword: UITextField!
   
    @IBOutlet weak var passwordCheck: UIImageView!
    @IBOutlet weak var newPasswordCheck: UIImageView!
    @IBOutlet weak var repeatNewPasswordCheck: UIImageView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        savePassword()
    }
    
    @IBAction func currentPasswordNext(_ sender: Any) {
        newPassword.becomeFirstResponder()
    }
    
    @IBAction func newPasswordNext(_ sender: Any) {
        repeatNewPassword.becomeFirstResponder()
    }
    
    @IBAction func repeatPasswordNext(_ sender: Any) {
        savePassword()
    }
    
   func savePassword() {
        // TODO: check that given password matches account?
        
        self.view.endEditing(true)
        
        if checkInputs() && checkRepeatPassword() {
            
            let alertController = UIAlertController(title: "Change Password", message: "Are you sure you want to change your password?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
            
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                
                HUD.show(.progress)
                
                if let email = self.email {
                    if let newPwd = self.newPassword.text {
                        
                        Asahi.sharedInstance.changePassword(email, newPassword: newPwd)
                            
                            .then{ response -> Void in
                                log.debug("Password changed")
                                HUD.flash(.success, delay:0.7)
                            }
                            
                            .catch{ err -> Void in
                                HUD.hide()
                                self.showAlert("Unable to change password", message: "")
                        }
                    } else {
                        HUD.hide()
                        self.showAlert("Unable to change password", message: "")
                    }
                } else {
                    HUD.hide()
                    self.showAlert("Unable to change password", message: "")
                }
            }
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
            
        else if !checkRepeatPassword() {
            let alertController = UIAlertController(title: "New Password", message: "Your passwords do not match.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
            
        else {
            let alertController = UIAlertController(title: "Oops!", message: "The information you provided is not valid.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change password"
        
        self.currentPassword.useCustomBottomBorder()
        self.newPassword.useCustomBottomBorder()
        self.repeatNewPassword.useCustomBottomBorder()

        self.passwordCheck.alpha = 0
        self.newPasswordCheck.alpha = 0
        self.repeatNewPasswordCheck.alpha = 0
        self.email = Settings.sharedInstance.userEmail
        _ = checkInputs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkInputs), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkInputs() -> Bool {
        
        // we want to make sure all of these checks are done so that the proper animations occur
        let currentPasswordValid = checkPassword(self.currentPassword, checkImage: self.passwordCheck)
        let newPasswordValid = checkPassword(self.newPassword, checkImage: self.newPasswordCheck)
        let repeatPasswordValid = checkRepeatPassword()
        
        return currentPasswordValid && newPasswordValid && repeatPasswordValid
    }
    
    func checkPassword(_ textField: UITextField, checkImage: UIImageView) -> Bool {
        if let pwd = textField.text {
            
            if pwd.isValidPwd() && checkImage.alpha == 0 {
                fadeIn(checkImage)
                return true
            }
            
            if !pwd.isValidPwd() {
                fadeOut(checkImage)
                return false
            }
            
            else {
                return true
            }
        }
        
        return false
    }
    
    func checkRepeatPassword() -> Bool {
        if let pwd = self.newPassword.text {
            if let rpwd = self.repeatNewPassword.text {
                
                if !pwd.isValidPwd() || pwd != rpwd {
                    fadeOut(self.repeatNewPasswordCheck)
                    return false
                }
            
                else {
                    fadeIn(self.repeatNewPasswordCheck)
                    return true
                }
            }
        }
        return false
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
