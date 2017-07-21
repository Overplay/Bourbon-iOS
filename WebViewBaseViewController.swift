//
//  WebViewBaseViewController.swift
//  Bourbon-iOS
//  
//  Parent class for VCs that use the webView in a similar fashion
//
//  Created by Mitchell Kahn on 4/3/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD

class WebViewBaseViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var targetUrlString: String?
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    
        webView.delegate = self
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
    
        // prevent user from scaling or pinch zooming
        webView.scalesPageToFit = false
        webView.isMultipleTouchEnabled = false
        
        // hide until loaded
        webView.alpha = 0
    
        // set title on navbar
    
        // configure request timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TimeInterval(10)
    
        goToTarget()
    }
    
    func goToTarget() {
    
        guard let turl = targetUrlString, let url = URL(string: turl) else {
            return
        }
    
        var urlReq = URLRequest(url: url,
                                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                timeoutInterval: 10)
        
        //headers: [ "Authorization" : "Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")" ])
        
        urlReq.setValue("Bearer \(Settings.sharedInstance.userBelliniJWT ?? "")", forHTTPHeaderField: "Authorization")
        urlReq.setValue("OGHomey", forHTTPHeaderField: "X-OG-Mobile")

    
        log.debug("url: \(url)")
    
        HUD.show(.labeledProgress(title: "Loading", subtitle: "Please wait"))
    
        self.webView.loadRequest(urlReq)
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        log.debug("Error loading webview: \(error)")
        
        let ecode = (error as NSError).code 
        if ecode == 102 {
            log.debug("Stupid frame load error 102, ignoring");
            return;
        }
        
        self.webViewDidTimeout()
    }
    
    func webViewDidTimeout() {
        
        HUD.hide()
    
        let alertController = UIAlertController(title: "Uh oh!", message: "There was a problem accessing the control view.", preferredStyle: .alert)
    
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(alert:UIAlertAction!) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
    
        alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: {(alert:UIAlertAction!) in
            self.goToTarget()
        }))
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        HUD.hide()
        UIView.animate(withDuration: 0.35) {
            self.webView.alpha = 1
        }
    }
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        HUD.hide()
        super.viewWillDisappear(animated)
    }
    
   
}
