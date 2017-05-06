//
//  CustomTextFieldDelegate.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/5/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class CustomTextFieldDelegate: NSObject {
    var errorLabel: UILabel?
    var isValid: (String?) -> Bool
    
    init(_ textField: UITextField, isValid: @escaping (String?) -> Bool, errorLabel: UILabel? = nil) {
        self.errorLabel = errorLabel
        self.isValid = isValid
        super.init()
        textField.delegate = self
        textField.useCustomBottomBorder()
    }
}

extension CustomTextFieldDelegate: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let el = self.errorLabel {
            el.isHidden = true
        }
        textField.changeBorderColor(UIColor.white)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isValid(textField.text) {
            if let el = self.errorLabel {
                el.isHidden = true
            }
            textField.changeBorderColor(UIColor.white)
            
        } else {
            if let el = self.errorLabel {
                el.isHidden = false
            }
            textField.changeBorderColor(UIColor.red)
        }
    }
}
