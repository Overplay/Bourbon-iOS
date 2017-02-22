//
//  CheckAppOpenedViewController.swift
//  Absinthe-iOS-X8
//
//  Created by Alyssa Torres on 2/17/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class CheckAppOpenedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Style.darkGreyColor
        
        // check if this is the first time opening the app
        log.info(Settings.sharedInstance.appOpened)
        
        if (Settings.sharedInstance.appOpened == false || Settings.sharedInstance.alwaysShowIntro == true) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
