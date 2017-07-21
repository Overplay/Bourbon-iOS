//
//  DevSettingsViewController.swift
//  Bourbon-iOS
//
//  Created by Mitchell Kahn on 7/21/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import PKHUD

class DevSettingsViewController: UIViewController {

    @IBOutlet var devServerSwitch: UISwitch!
    
    @IBAction func devServerSwitchChanged(_ sender: UISwitch) {
        
        
        let alertController = UIAlertController(title: "Change Server Setting", message: "This will force a logout!", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            Settings.sharedInstance.useDevServer = sender.isOn
            
            OGCloud.sharedInstance.logout()
                .always{
                    HUD.flash(.labeledSuccess(title: "Logged out!", subtitle: ""), delay: 0.5, completion: { (_) in
                        OGCloud.sharedInstance.updateServers()
                        self.performSegue(withIdentifier: "fromDevToRegistration", sender: nil)
                    })
                    
            }

            
        }
        
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            sender.isOn = !sender.isOn
        }
        
        alertController.addAction(cancelAction)
        
        // Present Dialog message
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devServerSwitch.isOn = Settings.sharedInstance.useDevServer

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
