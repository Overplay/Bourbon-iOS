//
//  AccountBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/18/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//
//  This is the ViewController that all Settings (a.k.a. Account) pages
//

import UIKit

class AccountBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func fadeIn(_ view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 1.0
        }) 
    }
    
    func fadeOut(_ view: UIView){
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0.0
        }) 
    }
    
    func fade(_ view: UIView, onCondition: Bool) {
        if onCondition {
            fadeIn(view)
        } else {
            fadeOut(view)
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
