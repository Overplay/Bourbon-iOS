//
//  DeviceControlView.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD

class DeviceViewController: WebViewBaseViewController {
    
    var ogDevice: OGDevice!
    var appDisplayName: String?
    var controlAppUrlString: String?
    
    
    override func viewDidLoad() {
        targetUrlString = self.ogDevice.getUrl()
        super.viewDidLoad()
        
        self.title = ogDevice.name
        
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let rUrl = request.url?.absoluteString,  let _ = rUrl.range(of: "app/control/index.html") {
            
            controlAppUrlString = rUrl
            self.performSegue(withIdentifier: "toAppControl", sender: self)
            return false
            
        }
        
        return true;
    
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAppControl" && sender != nil {
            (segue.destination as! WebViewBaseViewController).targetUrlString = controlAppUrlString
        }
    }
}
