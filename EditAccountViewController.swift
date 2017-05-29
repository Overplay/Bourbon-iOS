//
//  EditAccountViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/14/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

class EditAccountViewController: UITableViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var errorBlock: UIView!
    @IBOutlet weak var errorBlockLabel: UILabel!
    
    var firstNameDelegate: CustomTextFieldDelegate?
    var lastNameDelegate: CustomTextFieldDelegate?
    var emailDelegate: CustomTextFieldDelegate?
    
    @IBAction func save(_ sender: AnyObject) {
        self.view.endEditing(true)
        errorBlock.isHidden = true
        
        guard let first = firstName.text, isValidName(first),
            let last = lastName.text, isValidName(last),
            let email = email.text, isValidEmail(email)
            else {
                firstNameDelegate?.textFieldDidEndEditing(firstName)
                lastNameDelegate?.textFieldDidEndEditing(lastName)
                emailDelegate?.textFieldDidEndEditing(self.email)
                return
        }
        
        let alertController = UIAlertController(title: "Save",
                                                message: "Are you sure you want to save these changes?",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            HUD.show(.progress)
            
            if let uid = Settings.sharedInstance.userId {
                OGCloud.sharedInstance.changeAccountInfo(first, lastName: last, email: email, userId: uid)
            
                    .then{ response -> Void in
                        Settings.sharedInstance.userEmail = email
                        Settings.sharedInstance.userFirstName = first
                        Settings.sharedInstance.userLastName = last
                        
                        HUD.flash(.success, delay:0.7)
                    }
                
                    .catch{ error -> Void in
                        switch error {
                            
                        case OGCloudError.authFailure:
                            self.errorBlockLabel.text = "Sorry, it looks like you aren't authorized to change this account's information!"
                            self.errorBlock.isHidden = false
                            
                        case OGCloudError.tokenInvalid:
                            let alertController = UIAlertController(
                                title: "Uh oh!",
                                message: "It looks like your session has expired. Please log back in.",
                                preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                                OGCloud.sharedInstance.logout()
                                    .always{
                                        self.performSegue(withIdentifier: "fromEditAccountToRegistration", sender: nil)
                                    }
                            }
                            
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            
                        default:
                            self.errorBlockLabel.text = "Uh oh! Something went wrong changing your account info."
                            self.errorBlock.isHidden = false
                        }
                        HUD.hide()
                    }
            } else {
                self.errorBlockLabel.text = "Oh no! It looks like your account info might be out of date. Try logging out and logging back in."
                self.errorBlock.isHidden = false
                HUD.hide()
            }
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorBlock.isHidden = true
        
        firstNameDelegate = CustomTextFieldDelegate(firstName, isValid: isValidName, inTableView: true)
        lastNameDelegate = CustomTextFieldDelegate(lastName, isValid: isValidName, inTableView: true)
        emailDelegate = CustomTextFieldDelegate(email, isValid: isValidEmail,
                                                errorLabel: emailErrorLabel,
                                                inTableView: true)
        
        OGCloud.sharedInstance.checkSession()
            .then { _ -> Void in
                self.firstName.text = Settings.sharedInstance.userFirstName
                self.lastName.text = Settings.sharedInstance.userLastName
                self.email.text = Settings.sharedInstance.userEmail
                
            }.catch { error -> Void in
            
                let alertController = UIAlertController(title: "Uh oh!", message: "There was an issue getting your account information.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.performSegue(withIdentifier: "unwindToSettings", sender: nil)
                }
                    
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(_ string: String?) -> Bool {
        if let str = string {
            return str.isValidEmail()
        }
        return false
    }
    
    func isValidName(_ string: String?) -> Bool {
        if let str = string, str != "" {
            return true
        }
        return false
    }
}
