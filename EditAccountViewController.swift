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

class EditAccountViewController: AccountBaseViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var emailGoodCheck: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func closeEditAccount(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        self.view.endEditing(true)
        
        guard let first = self.firstName.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        guard let last = self.lastName.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        guard let email = self.email.text
            else {
                showAlert("Oops!", message: "The information you put in is not valid.")
                return
        }
        
        let alertController = UIAlertController(title: "Save Changes", message: "Are you sure you want to save changes to your account information?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        // TODO: change account information with call to Asahi and store new info in Settings
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            
            HUD.show(.progress)
            
            if let uid = Settings.sharedInstance.userId {
                Asahi.sharedInstance.changeAccountInfo(first, lastName: last, email: email, userId: uid)
            
                    .then{ response -> Void in
                        Settings.sharedInstance.userEmail = email
                        Settings.sharedInstance.userFirstName = first
                        Settings.sharedInstance.userLastName = last
                        
                        HUD.flash(.success, delay:0.7)
                    }
                
                    .catch{ err -> Void in
                        HUD.hide()
                        self.showAlert("Unable to change account info", message: "")
                    }
            } else {
                HUD.hide()
                self.showAlert("Unable to change account info", message: "")
            }
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailGoodCheck.alpha = 0
        self.saveButton.alpha = 0

        self.firstName.text = Settings.sharedInstance.userFirstName
        self.lastName.text = Settings.sharedInstance.userLastName
        self.email.text = Settings.sharedInstance.userEmail
        checkEmail()
        
        Asahi.sharedInstance.checkJWT()
            .then { response -> Void in
                log.debug("JWT check good")
                if let first = response["firstName"].string {
                    Settings.sharedInstance.userFirstName = first
                    self.firstName.text = first
                }
                
                if let last = response["lastName"].string {
                    Settings.sharedInstance.userLastName = last
                    self.lastName.text = last
                }
                
                if let email = response["email"].string {
                    Settings.sharedInstance.userEmail = email
                    self.email.text = email
                    self.checkEmail()
                }
                
                if let userId = response["id"].string {
                    Settings.sharedInstance.userId = userId
                }

        }
            .catch { error -> Void in
                log.debug("BAD JWT")
                let alertController = UIAlertController(title: "Uh oh!", message: "It looks like your session has expired. Please log back in.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    Asahi.sharedInstance.logout()
                    self.performSegue(withIdentifier: "fromEditAccountToRegistration", sender: nil)
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                /*switch error {
                    
                case Asahi.AsahiError.authFailure:
                    self.showAlert("Uh oh!", message: "You aren't authorized to access this resource.")
                    
                case Asahi.AsahiError.tokenInvalid:
                    let alertController = UIAlertController(title: "Uh oh!", message: "It looks like your session has expired. Please log back in.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        Asahi.sharedInstance.logout()
                        self.performSegue(withIdentifier: "fromEditAccountToRegistration", sender: nil)
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                default:
                    self.showAlert("Uh oh!", message: "There was an issue loading your account information.")
                }*/
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkEmail), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkEmail() {
        
        if let email = self.email.text {
            
            if email.isValidEmail() && self.emailGoodCheck.alpha == 0 {
                fadeIn(self.emailGoodCheck)
                fadeIn(self.saveButton)
            }
            
            if !email.isValidEmail() {
                fadeOut(self.emailGoodCheck)
                fadeOut(self.saveButton)
            }
        }
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
