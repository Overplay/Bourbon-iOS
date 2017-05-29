//
//  AccountViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD


// TODO: This is a bit messy with all the initters
struct SettingsOption {
    let label: String
    var image: String? = nil
    var segue: String? = nil
    var action: Selector? = nil
    
    init(label: String) {
        self.label = label
    }
    
    init(label: String, image: String) {
        self.label = label
        self.image = image
    }
    
    init(label: String, segue: String) {
        self.label = label
        self.segue = segue
    }
    
    init(label: String, action: Selector ) {
        self.label = label
        self.action = action
    }

}

class SettingsViewController : AccountBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) { }
    
    var tableView: UITableView!
    
    let options = [
        SettingsOption(label: "My Venues", segue: "fromSettingsToVenues"),
        SettingsOption(label: "Setup OG Device", segue: "fromSettingsToSetup"),
        //SettingsOption(label: "Invite Friends", segue: "fromSettingsToInvite"),
        SettingsOption(label: "Edit Account", segue: "fromSettingsToEdit"),
        SettingsOption(label: "Log Out", action: #selector(logout)),
        SettingsOption(label: "", action: #selector(secret)),

    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = self.view as! UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let op = options[indexPath.row]
        
        if let segue = op.segue {
            self.performSegue(withIdentifier: segue , sender: self)
        }
        
        if op.action != nil {
            self.perform(op.action)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsCell
        
        cell.isUserInteractionEnabled = true
        
        let op = options[indexPath.row]
        
        cell.label.text = op.label
        
        if op.segue == nil {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func logout() -> Void {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            OGCloud.sharedInstance.logout()
                .always{
                    HUD.flash(.labeledSuccess(title: "Logged out!", subtitle: ""), delay: 0.5, completion: { (_) in
                        self.performSegue(withIdentifier: "fromSettingsToRegistration", sender: nil)
                    })
                    
            }
            
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func secret(){
        log.debug("secret!");
        //ASNotification.error403.issue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let op = sender as? SettingsOption {
            segue.destination.title = op.label
        }
    }
}
