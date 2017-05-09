//
//  UIImageViewExtensions.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/5/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageFromURL(_ url: String) {
        if let url = URL(string: url) {
            do {
                try self.image = UIImage(data: Data(contentsOf: url))
            } catch {
                log.error("unable to load image")
            }
        }
    }
}
