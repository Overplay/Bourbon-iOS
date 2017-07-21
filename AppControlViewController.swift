//
//  AppControlViewController.swift
//  Bourbon-iOS
//
//  Created by Mitchell Kahn on 4/3/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class AppControlViewController: WebViewBaseViewController {
    
    var displayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // it's a jump to a control page
        if let comps = self.targetUrlString?.components(separatedBy: "displayName=") {
            
            if comps.count == 2 {
                displayName = comps[1]
            } else {
                displayName = "OURGLASS"
            }
            
        }
        
        self.title = displayName?.removingPercentEncoding
    }

    

}
