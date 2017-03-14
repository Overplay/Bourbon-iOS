//
//  DeviceControlView.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 3/13/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD

class DeviceViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var ogDevice: OGDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        self.webView.delegate = self
        self.webView.scrollView.isScrollEnabled = true
        self.webView.scrollView.bounces = true
        
        // prevent user from scaling or pinch zooming
        self.webView.scalesPageToFit = false
        self.webView.isMultipleTouchEnabled = false
        
        // set title on navbar
        self.navigationItem.title = ogDevice.name
        
        // configure request timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TimeInterval(10)
        
        self.goToControlPage()
    }
    
    func goToControlPage() {
        
        guard let url = URL(string: self.ogDevice.getUrl()) else {
            return
        }
        
        let urlReq = URLRequest(url: url,
                                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                timeoutInterval: 10)
        
        log.debug("url: \(url)")
        
        HUD.show(.labeledProgress(title: "Loading", subtitle: "Please wait"))
        
        self.webView.loadRequest(urlReq)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        log.debug("Error loading webview: \(error)")
        self.webViewDidTimeout()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let requestUrlString = request.url?.absoluteString
        
        // check if we need to navigate to a new view controller for the incoming url
        if (requestUrlString?.range(of: self.ogDevice.getUrl()) != nil) {
            return true
        }
        
        // self.performSegue(withIdentifier: "toAppControl", sender: requestUrlString!)
        
        return false
    }
    
    func webViewDidTimeout() {
        HUD.hide()
        
        let alertController = UIAlertController(title: "Uh oh!", message: "We were unable to access the device.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(alert:UIAlertAction!) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: {(alert:UIAlertAction!) in
            self.goToControlPage()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        HUD.hide()
    }
    
    // MARK: - Navigation
    
    override func viewWillDisappear(_ animated: Bool) {
        HUD.hide()
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAppControl" && sender != nil {
            // TODO
        }
    }
}
