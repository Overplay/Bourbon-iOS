//
//  AccountViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/1/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PKHUD

struct SettingsOption {
    let label: String
    let image: String?
    
    init(label: String) {
        self.label = label
        self.image = nil
    }
    
    init(label: String, image: String) {
        self.label = label
        self.image = image
    }
}

class AccountViewController : AccountBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var tableView: UITableView!
    
    let options = [
        //SettingsOption(label: "Invite Friends", image: "ic_card_giftcard_white_18pt"),
        SettingsOption(label: "Setup OG Device", image: ""),
        SettingsOption(label: "Edit Account", image: "ic_perm_identity_white_18pt"),
        // SettingsOption(label: "Add/Manage Venues", image: "ic_add_location_white_18pt"),
        SettingsOption(label: "Log Out", image: "ic_first_page_white_18pt")]
    
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
        
        switch op.label {
        case "Setup OG Device":
            self.performSegue(withIdentifier: "fromAccountToSetup", sender: op)
        case "Invite Friends":
            self.performSegue(withIdentifier: "fromAccountToInvite", sender: op)
        case "Edit Account":
            self.performSegue(withIdentifier: "fromAccountToEdit", sender: op)
        case "Log Out":
            logout()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsCell
        
        cell.isUserInteractionEnabled = true
        
        cell.label.text = options[indexPath.row].label
        
        if options[indexPath.row].label == "Log Out" {
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
    
    func logout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            Asahi.sharedInstance.logout()
            HUD.flash(.labeledSuccess(title: "Logged out!", subtitle: ""), delay: 0.5, completion: { (_) in
                self.performSegue(withIdentifier: "fromAccountToRegistration", sender: nil)
            })
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)

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
