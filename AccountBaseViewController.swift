//
//  AccountBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/18/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class AccountBaseViewController: UIViewController {
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func fadeIn(_ view: UIView){
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 1
        }) 
    }
    
    func fadeOut(_ view: UIView){
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 0
        }) 
    }
    
    func showAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
