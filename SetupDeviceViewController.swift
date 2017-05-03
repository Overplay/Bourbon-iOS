//
//  SetupDeviceViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 4/24/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class SetupDeviceViewController: AccountBaseViewController {
    
    @IBOutlet weak var regCodeLabel: UILabel!
    @IBOutlet weak var regCode: UITextField!
    @IBOutlet weak var regCodeErrorLabel: UILabel!
    
    @IBOutlet weak var deviceName: UITextField!
    @IBOutlet weak var deviceNameCheck: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameErrorLabel: UILabel!
    
    @IBOutlet weak var chooseVenue: UIButton!
    @IBOutlet weak var chooseVenueErrorLabel: UILabel!
    
    @IBOutlet weak var createDeviceButton: UIButton!
    @IBOutlet weak var createDeviceActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorBlock: UIView!
    @IBOutlet weak var errorBlockLabel: UILabel!
    
    var venue: OGVenue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.errorBlock.isHidden = true
        
        self.regCode.useCustomBottomBorder()
        self.deviceName.useCustomBottomBorder()
        
        let disclosure = UITableViewCell()
        disclosure.frame = chooseVenue.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        chooseVenue.addSubview(disclosure)
    }
    
    @IBAction func regCodeNext(_ sender: Any) {
        self.deviceName.becomeFirstResponder()
    }
    
    @IBAction func regCodeEditingDidEnd(_ sender: Any) {
        if self.isValidRegCode(self.regCode.text) {
            self.regCodeErrorLabel.isHidden = true
            self.regCode.changeBorderColor(UIColor.white)
        }
            
        else {
            self.regCodeErrorLabel.isHidden = false
            self.regCode.changeBorderColor(UIColor.red)
        }

    }
    
    @IBAction func regCodeBeginEditing(_ sender: Any) {
        self.regCodeErrorLabel.isHidden = true
        self.regCode.changeBorderColor(UIColor.white)
    }
    
    @IBAction func deviceNameNext(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func deviceNameEditingDidEnd(_ sender: Any) {
        if self.isValidDeviceName(deviceName.text) {
            self.deviceNameErrorLabel.isHidden = true
            self.deviceName.changeBorderColor(UIColor.white)
            
        } else {
            deviceNameErrorLabel.isHidden = false
            deviceName.changeBorderColor(UIColor.red)
        }
    }
    
    @IBAction func deviceNameBeginEditing(_ sender: Any) {
        self.deviceNameErrorLabel.isHidden = true
        self.deviceName.changeBorderColor(UIColor.white)
    }
    
    @IBAction func createDevice(_ sender: Any) {
        self.view.endEditing(true)
        self.errorBlock.isHidden = true
        self.createDeviceButton.isEnabled = false
        self.createDeviceButton.alpha = 0.5
        self.createDeviceActivityIndicator.startAnimating()
        
        guard let name = self.deviceName.text, let code = self.regCode.text,
            let venue = self.venue, isValidRegCode(code), isValidDeviceName(name) else {
                
                deviceNameEditingDidEnd(sender)
                regCodeEditingDidEnd(sender)
            
                if self.venue == nil {
                    self.chooseVenueErrorLabel.isHidden = false
                }
                
                self.createDeviceButton.isEnabled = true
                self.createDeviceButton.alpha = 1.0
                self.createDeviceActivityIndicator.stopAnimating()
                return
        }
        
        Asahi.sharedInstance.findByRegCode(code)
            .then { response -> Void in
                log.debug(response)
        }
            .catch { error -> Void in
                switch error {
                    
                case Asahi.AsahiError.authFailure:
                    self.errorBlockLabel.text = "Sorry, it looks like you aren't authorized to create a device!"
                    self.errorBlock.isHidden = false
                    
                case Asahi.AsahiError.tokenInvalid:
                    let alertController = UIAlertController(title: "Uh oh!", message: "It looks like your session has expired. Please log back in.", preferredStyle: .alert)
                    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PickVenueViewController {
            vc.delegate = self
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

extension SetupDeviceViewController: PickVenueViewControllerDelegate {
    func pickVenue(_ venue: OGVenue) {
        self.venue = venue
        self.chooseVenueErrorLabel.isHidden = true
        
        let titleFont = UIFont(name: Style.regularFont, size: 17.0)
        let subtitleFont = UIFont(name: Style.lightFont, size: 12.0)
        let buttonText = NSMutableAttributedString(string: "\(venue.name)\n\(venue.address)")
        
        buttonText.addAttribute(NSFontAttributeName, value: titleFont!, range: NSMakeRange(0, venue.name.characters.count))
        buttonText.addAttribute(NSFontAttributeName, value: subtitleFont!, range: NSMakeRange(venue.name.characters.count+1, venue.address.characters.count))
        self.chooseVenue.setAttributedTitle(buttonText, for: .normal)
    }
}
