//
//  FindYelpVenuesViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/4/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class FindYelpVenuesViewController: UIViewController {
    
    @IBOutlet weak var yelpTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
