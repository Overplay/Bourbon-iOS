//
//  ChangePasswordViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/17/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

class ChangePasswordViewController: UITableViewController {
    
    @IBOutlet weak var curPwd: UITextField!
    @IBOutlet weak var curPwdErrorLabel: UILabel!
    
    @IBOutlet weak var newPwd: UITextField!
    @IBOutlet weak var newPwdErrorLabel: UILabel!
    
    @IBOutlet weak var repeatPwd: UITextField!
    @IBOutlet weak var repeatPwdErrorLabel: UILabel!
    
    @IBOutlet weak var errorBlock: UIView!
    @IBOutlet weak var errorBlockLabel: UILabel!
 
    var curPwdDelegate: CustomTextFieldDelegate?
    var newPwdDelegate: CustomTextFieldDelegate?
    var repeatPwdDelegate: CustomTextFieldDelegate?
 
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        HUD.show(.progress)
        self.view.endEditing(true)
        errorBlock.isHidden = true
        repeatPwdErrorLabel.text = ""
        
        // check that there are valid passwords in each field
        guard let cur = curPwd.text, isValidPwd(cur),
            let new = newPwd.text, isValidPwd(new),
            let rpt = repeatPwd.text, isValidPwd(rpt) else {
                
                HUD.hide()
                curPwdDelegate?.textFieldDidEndEditing(curPwd)
                newPwdDelegate?.textFieldDidEndEditing(newPwd)
                repeatPwdDelegate?.textFieldDidEndEditing(repeatPwd)
                return
        }
        
        // check that the new and repeat passwords are equal
        guard new == rpt else {
            HUD.hide()
            repeatPwdErrorLabel.text = "Oops! The passwords don't match!"
            repeatPwdErrorLabel.isHidden = false
            repeatPwd.changeBorderColor(UIColor.red)
            repeatPwd.shake()
            return
        }
        
        // check that we have an email
        guard let email = Settings.sharedInstance.userEmail else {
            HUD.hide()
            errorBlockLabel.text = "Oh no! Your account information out-of-date. Try logging back in."
            errorBlock.isHidden = false
            errorBlock.shake()
            return
        }
        
        OGCloud.sharedInstance.login(email, password: cur).then { _ -> Void in
            
            // current password is correct, move on to changing the password
            OGCloud.sharedInstance.changePassword(email, newPassword: new).then { _ -> Void in
                
                // password successfully changed
                HUD.flash(.success, delay: 0.7)
                self.dismiss(animated: true, completion: nil)
                
                // there was an error changing the password
                }.catch { error -> Void in
                    HUD.hide()
                    self.errorBlockLabel.text = "Something went wrong changing your password."
                    self.errorBlock.isHidden = false
                    self.errorBlock.shake()
                }
            
        // the current password is incorrect
        }.catch { error -> Void in
            HUD.hide()
            self.curPwdErrorLabel.isHidden = false
            self.curPwd.changeBorderColor(UIColor.red)
            self.curPwd.shake()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorBlock.isHidden = true
        repeatPwdErrorLabel.text = ""
        
        curPwdDelegate = CustomTextFieldDelegate(curPwd,
                                                 isValid: isValidPwd,
                                                 errorLabel: curPwdErrorLabel,
                                                 inTableView: true)
        newPwdDelegate = CustomTextFieldDelegate(newPwd,
                                                 isValid: isValidPwd,
                                                 errorLabel: newPwdErrorLabel,
                                                 inTableView: true)
        repeatPwdDelegate = CustomTextFieldDelegate(repeatPwd,
                                                 isValid: isValidPwd,
                                                 errorLabel: repeatPwdErrorLabel,
                                                 inTableView: true)
    }

    func isValidPwd(_ string: String?) -> Bool {
        if let str = string {
            return str.isValidPwd()
        }
        return false
    }
}
