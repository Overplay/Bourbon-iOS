//
//  StringExtensions.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/20/16.
//  Copyright © 2016 Ourglass. All rights reserved.
//

import Foundation


extension String {
    
    func blank() -> Bool {
        let trimmed = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
        
    }
    
    func isValidPwd() -> Bool {
        
        let pwdRegEx = ".{5,}"
        //let pwdRegEx = "^(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@",pwdRegEx)
        let result = passwordTest.evaluate(with: self)
        return result
               
    }
    
    // This is really shitty!
    func munge() -> String {
        
        var bytes = Array<UInt8>()
        
        for c in self.utf8 {
            bytes.append(c+1)
        }
        
        let munged = String(describing: bytes)
        
        return munged
        
    }
    
    func trunc(_ length: Int, trailing: String? = "") -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
}
