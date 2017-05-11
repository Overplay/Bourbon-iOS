//
//  SetupDeviceViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 4/24/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import PKHUD

class SetupDeviceViewController: AccountBaseViewController {
    
    @IBOutlet weak var regCodeLabel: UILabel!
    @IBOutlet weak var regCode: UITextField!
    @IBOutlet weak var regCodeErrorLabel: UILabel!
    
    @IBOutlet weak var deviceName: UITextField!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameErrorLabel: UILabel!
    
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    
    @IBOutlet weak var createDeviceButton: UIButton!
    @IBOutlet weak var createDeviceActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorBlock: UIView!
    @IBOutlet weak var errorBlockLabel: UILabel!
    
    var regCodeDelegate: UITextFieldDelegate?
    var deviceNameDelegate: UITextFieldDelegate?
    
    var selectedVenue: OGVenue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorBlock.isHidden = true
        
        // setup text field delegates
        regCodeDelegate = CustomTextFieldDelegate(regCode, isValid: isValidRegCode, errorLabel: regCodeErrorLabel)
        deviceNameDelegate = CustomTextFieldDelegate(deviceName, isValid: isValidDeviceName, errorLabel: deviceNameErrorLabel)
        
        guard let venue = self.selectedVenue else {
            // there was no venue selected
            log.error("no venue chosen, this should not happen")
            self.venueName.text = "Please choose a venue."
            self.venueName.textColor = UIColor.red
            self.venueAddress.isHidden = true
            return
        }
        
        self.venueName.text = venue.name
        self.venueAddress.text = venue.address
    }
    
    @IBAction func createDevice(_ sender: Any) {
        self.view.endEditing(true)
        self.errorBlock.isHidden = true
        self.createDeviceButton.isEnabled = false
        self.createDeviceButton.alpha = 0.5
        self.createDeviceActivityIndicator.startAnimating()
        
        guard let name = self.deviceName.text, let code = self.regCode.text,
            let venue = self.selectedVenue, isValidRegCode(code), isValidDeviceName(name) else {
                
                // trigger errors on the text fields if there is not valid input
                regCodeDelegate?.textFieldDidEndEditing!(regCode)
                deviceNameDelegate?.textFieldDidEndEditing!(deviceName)
            
                if self.selectedVenue == nil {
                    self.venueName.text = "Please choose a venue."
                    self.venueName.textColor = UIColor.red
                    self.venueAddress.isHidden = true
                }
                
                self.createDeviceButton.isEnabled = true
                self.createDeviceButton.alpha = 1.0
                self.createDeviceActivityIndicator.stopAnimating()
                return
        }
        
        Asahi.sharedInstance.findByRegCode(code).then { deviceData -> Promise<String> in
            guard let deviceUdid = deviceData["deviceUDID"].string else {
                throw AsahiError.malformedJson
            }
            return Asahi.sharedInstance.changeDeviceName(deviceUdid, name: name)
            
        }.then { deviceUdid in
            return Asahi.sharedInstance.associate(deviceUdid: deviceUdid,
                                           withVenueUuid: venue.uuid)
        }.then { _ -> Void in
            self.createDeviceActivityIndicator.stopAnimating()
            self.createDeviceButton.isEnabled = true
            self.createDeviceButton.alpha = 1.0
            HUD.flash(.success, delay: 1.0)
            
            // unwind to main settings page
            self.performSegue(withIdentifier: "unwindToSettings", sender: nil)
        
        }.catch { error -> Void in
            
            switch error {
                    
            case AsahiError.authFailure:
                self.errorBlockLabel.text = "Sorry, it looks like you aren't authorized to create a device!"
                self.errorBlock.isHidden = false
                self.errorBlock.shake()
                    
            case AsahiError.tokenInvalid:
                let alertController = UIAlertController(
                    title: "Uh oh!",
                    message: "It looks like your session has expired. Please log back in.",
                    preferredStyle: .alert)
                    
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    Asahi.sharedInstance.logout()
                    self.performSegue(withIdentifier: "fromSetupDeviceToRegistration", sender: nil)
                }
                    
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                    
            default: // reg code was invalid
                self.regCodeErrorLabel.isHidden = false
                self.regCode.changeBorderColor(UIColor.red)
            }
                
            self.createDeviceButton.isEnabled = true
            self.createDeviceButton.alpha = 1.0
            self.createDeviceActivityIndicator.stopAnimating()
        }
        
    }

    func isValidRegCode(_ code: String?) -> Bool {
        let regexp = "^[a-zA-Z][0-9][a-zA-Z]{2}$"
        if let _ = code?.range(of: regexp, options: .regularExpression) {
            return true
        }
        return false
    }
    
    func isValidDeviceName(_ name: String?) -> Bool {
        if name != nil && name != "" {
            return true
        }
        return false
    }
}
