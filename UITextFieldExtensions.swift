//
//  TextFieldExtensions.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 4/28/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import Foundation
import UIKit

var borderLayers = NSMutableArray()

extension UITextField {
    
    func useCustomBottomBorder() {
        self.borderStyle = .none
        let border = CALayer()
        let width = CGFloat(1.0)
        
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        
        borderLayers.add(border)
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func removeBottomBorder() {
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if borderLayers.contains(layer) {
                    layer.removeFromSuperlayer()
                    borderLayers.remove(layer)
                }
            }
        }
    }
    
    func changeBorderColor(_ color: UIColor) {
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                if borderLayers.contains(layer) {
                    layer.borderColor = color.cgColor
                }
            }
        }
    }
}
