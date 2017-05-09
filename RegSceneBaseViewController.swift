//
//  RegSceneBaseViewController.swift
//  Absinthe-iOS
//
//  Created by Mitchell Kahn on 9/21/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class RegSceneBaseViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func fadeIn(_ view: UIView) {
        if view.alpha == 0 {
            UIView.animate(withDuration: 0.35, animations: {
                view.alpha = 1
            })
        }
    }
    
    func fadeOut(_ view: UIView) {
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 0
        }) 
    }
    
    func fade(_ view: UIView, onCondition: Bool) {
        if onCondition {
            fadeIn(view)
        } else {
            fadeOut(view)
        }
    }

}
