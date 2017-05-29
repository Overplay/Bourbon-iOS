//
//  CheckAppOpenedViewController.swift
//  Absinthe-iOS-X8
//
//  Created by Alyssa Torres on 2/17/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class CheckAppOpenedViewController: UIViewController {
    
    let alwaysForceSlides = false; // set true for testing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Style.darkGreyColor
        
        // check if this is the first time opening the app
        if (alwaysForceSlides ||
            Settings.sharedInstance.appOpened == false ||
            Settings.sharedInstance.alwaysShowIntro == true) {
            
            Settings.sharedInstance.appOpened = true
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "fromCheckToSlides", sender: nil)
            })
            
        } else {
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "fromCheckToReg", sender: nil)
            })
        }
    }
    
}
