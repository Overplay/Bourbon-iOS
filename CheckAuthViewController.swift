//
//  CheckAuthViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/24/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PromiseKit
import PKHUD


class CheckAuthViewController: UIViewController {
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        //HUD.show(.labeledProgress(title: "Contacting OG Cloud", subtitle: "Please Wait"))
        OGCloud.sharedInstance.checkJWT()
            .then{ _ -> Void in
                //HUD.flash(.success)
                self.performSegue(withIdentifier: "fromCheckAuthToMainTabs", sender: self)

        }
            .catch{ err in
                //HUD.flash(.error)
                self.performSegue(withIdentifier: "fromCheckAuthToLR", sender: self)

        }
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }


}
