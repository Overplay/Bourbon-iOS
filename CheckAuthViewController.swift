//
//  CheckAuthViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/24/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PromiseKit


class CheckAuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segue = Settings.sharedInstance.hasValidJwt ? "fromCheckAuthToMainTabs" : "fromCheckAuthToLR"
        self.performSegue(withIdentifier: segue, sender: self)

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }


}
