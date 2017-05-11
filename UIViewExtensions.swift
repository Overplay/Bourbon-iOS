//
//  UIViewExtensions.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/10/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
