//
//  CustomTextFieldDelegate.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/5/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

/// A custom text field delegate that handles editing and applies a common style.
class CustomTextFieldDelegate: NSObject {
    var errorLabel: UILabel?
    var isValid: (String?) -> Bool
    var textField: UITextField
    
    init(_ textField: UITextField, isValid: @escaping (String?) -> Bool, errorLabel: UILabel? = nil) {
        self.errorLabel = errorLabel
        self.isValid = isValid
        self.textField = textField
        super.init()
        textField.delegate = self
        
        // do some styling
        textField.useCustomBottomBorder()
        
        if let el = self.errorLabel {
            el.textColor = UIColor.red
        }
        
       
    }
    
    func style(str: String) -> Bool {
        return true
    }
}

extension CustomTextFieldDelegate: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let el = self.errorLabel {
            el.isHidden = true
        }
        self.textField.changeBorderColor(UIColor.white)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isValid(self.textField.text) {
            if let el = self.errorLabel {
                el.isHidden = true
            }
            self.textField.changeBorderColor(UIColor.white)
            
        } else {
            if let el = self.errorLabel {
                el.isHidden = false
            }
            self.textField.changeBorderColor(UIColor.red)
        }
    }
}
