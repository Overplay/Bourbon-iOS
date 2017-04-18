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
        SettingsOption(label: "Edit Account", image: "ic_perm_identity_white_18pt"),
        //SettingsOption(label: "Add New Ourglass Device", image: "ic_queue_play_next_white_18pt"),
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
        
        switch options[indexPath.row].label {
        case "Invite Friends":
            inviteFriends()
        case "Edit Account":
            self.performSegue(withIdentifier: "fromAccountToEdit", sender: nil)
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
        
        if let image = options[indexPath.row].image {
            cell.icon.image = UIImage(named: image)
        }
        
        return cell
    }
    
    func logout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) in }
        
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            Asahi.sharedInstance.logout()
            HUD.flash(.labeledSuccess(title: "Logged out!", subtitle: ""), delay: 1.0, completion: { (_) in
                self.performSegue(withIdentifier: "fromAccountToRegistration", sender: nil)
            })
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func inviteFriends() {
        self.performSegue(withIdentifier: "fromAccountToInvite", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
