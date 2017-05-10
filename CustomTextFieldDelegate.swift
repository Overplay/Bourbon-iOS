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
    var inTableView: Bool
    
    init(_ textField: UITextField, isValid: @escaping (String?) -> Bool, errorLabel: UILabel? = nil, inTableView: Bool = false) {
        self.errorLabel = errorLabel
        self.isValid = isValid
        self.textField = textField
        self.inTableView = inTableView
        super.init()
        textField.delegate = self
        
        applyTextFieldStyle()
        applyErrorLabelStyle()
    }
    
    
    /// Applies a default style to the text field.
    func applyTextFieldStyle() {
        textField.useCustomBottomBorder()
        textField.textColor = UIColor.white
        textField.font = UIFont(name: Style.regularFont, size: 17.0)
    }
    
    /// Applies a default style to the error label.
    func applyErrorLabelStyle() {
        if let el = errorLabel {
            el.isHidden = true
            el.textColor = UIColor.red
            el.font = UIFont(name: Style.lightFont, size: 11.0)
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.inTableView, let nextField = textField.superview?.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            
        } else if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()

        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
