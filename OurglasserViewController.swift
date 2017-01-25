//
//  FirstViewController.swift
//  OurglassAppSwift
//
//  Created by Alyssa Torres on 3/1/16.
//  Copyright © 2016 App Delegates. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD

class OurglasserViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBAction func disme(_ sender: UIButton) {
        self.timer.invalidate()
        HUD.hide()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Set in initialization
    var op: OPIE!
    // Use to tell it to refresh when we go back to it
    var chooseViewController: ChooseOurglasserViewController!
    var goToUrl = String()
    var navTitle = String()
    
    var timer = Timer() // check for device still alive
    var timeoutTimer = Timer() // check for web page slow load
    var interval = 10  // seconds
    var requestTimeout = 5  // seconds for device disappear
    var timeoutTime = 30 // seconds for web page timeout (slow load)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.responds(to: #selector(getter: UIViewController.automaticallyAdjustsScrollViewInsets)) {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.webView.delegate = self
        self.webView.scrollView.isScrollEnabled = true
        self.webView.scrollView.bounces = true
        //prevent user from scaling or pinch zooming
        self.webView.scalesPageToFit = false
        self.webView.isMultipleTouchEnabled = false
        
        goToApps()
        
        self.navigationController?.topViewController?.title = self.navTitle
        
        // Configure request timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TimeInterval(self.requestTimeout)
        
        //startPageLoadTimeout()
        
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    func goToApps() {
        // MAK this was not the right way to handle timeouts
        //startPageLoadTimeout()
        let url = URL(string: self.goToUrl)
        let urlR = URLRequest(url: url!,
                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                    timeoutInterval: 15)
        
        HUD.show(.labeledProgress(title: "Loading", subtitle: "Please Wait"))

        webView.loadRequest(urlR)
        
    }
    
    func webView(_ webView: UIWebView,
                 didFailLoadWithError error: Error){
        
        log.debug("Error loading webview: \(error)")
        webViewDidTimeOut()
    }

    
    func startPageLoadTimeout() {

        HUD.show(.labeledProgress(title: "Loading", subtitle: "Please Wait"))
        
        if(timeoutTimer.isValid) {
            timeoutTimer.invalidate()
        }
        
        // Wait 30 seconds for slow page load
        timeoutTimer = Timer.scheduledTimer(timeInterval: TimeInterval(self.timeoutTime),
                                            target: self,
                                            selector: #selector(webViewDidTimeOut),
                                            userInfo: nil,
                                            repeats: false)
    }
    
    func webViewDidTimeOut() {

        HUD.hide()
        
        let alertController = UIAlertController(title: "Network Error", message: "There appears to be an issue communicating with the Ourglass device.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert:UIAlertAction!) in
            // If main controller
            if self.goToUrl.range(of: "/www/control/index.html") != nil {
                //TODO: this violates seperation of concerns. Needs to be rewritten.
//                let opIndex = OPIEBeaconListener.sharedInstance.opies.index(where: {
//                    $0.ipAddress == self.op.ipAddress
//                })
//                OPIEBeaconListener.sharedInstance.opies.remove(at: opIndex!)
//                NotificationCenter.default.post(name: Notification.Name(rawValue: ASNotification.droppedOPIE.rawValue), object: nil, userInfo: ["OPIE": self.op])
                //self.chooseViewController.shouldFindAfterAppear = true
            }
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Try Again", style: .default, handler: {(alert: UIAlertAction!) in
            self.goToApps()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        HUD.hide()
//        if self.timeoutTimer.isValid {
//            self.timeoutTimer.invalidate()
//        }
    }
    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let requestUrlString = request.url?.absoluteString
        
        // If is loading url that it is supposed to load in view controller initially, allow through
        // Use rangeOfString and not checking exact match because some app controllers have subpages with ui-router
        // i.e., index.html#/home instead of just index.html
        if requestUrlString?.range(of: self.goToUrl) != nil {
            return true
        }
        
        // If is not main url, go to new controller
        self.performSegue(withIdentifier: "toAppControl", sender: [requestUrlString!, self.navTitle])
        
        return false
        
    }
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        HUD.hide()
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAppControl" && sender != nil {
            let ovc : OurglasserViewController = segue.destination as! OurglasserViewController
            
            //TODO WTF is all this??
            var args = sender as! [String]
            ovc.goToUrl = args[0]
            ovc.navTitle = args[1]
            // Modify back button BEFORE pushing because the object actually belongs to previous/current view controller (self), not the one being currently shown/pushed (ovc)
            let backButton = UIBarButtonItem(title: "Control Panel", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backButton
        }
    }
}
