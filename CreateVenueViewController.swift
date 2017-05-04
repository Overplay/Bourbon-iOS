//
//  CreateVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/3/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class CreateVenueViewController: AccountBaseViewController {
    
    @IBOutlet weak var yelpSearchTerm: UITextField!
    @IBOutlet weak var yelpSearchLocation: UITextField!
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var venueName: UITextField!
    @IBOutlet weak var address1: UITextField!
    @IBOutlet weak var address2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        
    }
    
    @IBAction func yelpSearchTermEditingChanged(_ sender: Any) {
        checkReadyToYelp()
    }
    
    @IBAction func yelpSearchLocationEditingChanged(_ sender: Any) {
        checkReadyToYelp()
    }
    
    func checkReadyToYelp() {
        guard let searchTerm = yelpSearchTerm.text, let location = yelpSearchLocation.text else {
            findButton.isEnabled = false
            findButton.alpha = 0.5
            return
        }
        
        if searchTerm == "" || location == "" {
            findButton.isEnabled = false
            findButton.alpha = 0.5
            return
        }
        
        // TODO: actually check location
        findButton.isEnabled = true
        fadeIn(findButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        venueName.useCustomBottomBorder()
        address1.useCustomBottomBorder()
        address2.useCustomBottomBorder()
        city.useCustomBottomBorder()
        state.useCustomBottomBorder()
        zip.useCustomBottomBorder()
        
        yelpSearchTerm.useCustomBottomBorder()
        let searchImageView = UIImageView()
        searchImageView.image = #imageLiteral(resourceName: "ic_search_white_36pt")
        searchImageView.alpha = 0.5
        searchImageView.frame = CGRect(x: 5, y: 0, width: yelpSearchTerm.frame.height, height: yelpSearchTerm.frame.height)
        yelpSearchTerm.leftView = searchImageView
        yelpSearchTerm.leftViewMode = .always
        
        yelpSearchLocation.useCustomBottomBorder()
        let locationImageView = UIImageView()
        locationImageView.image = #imageLiteral(resourceName: "ic_place_white")
        locationImageView.alpha = 0.5
        locationImageView.frame = CGRect(x: 5, y: 0, width: yelpSearchLocation.frame.height, height: yelpSearchLocation.frame.height)
        yelpSearchLocation.leftView = locationImageView
        yelpSearchLocation.leftViewMode = .always
        
        findButton.isEnabled = false
        findButton.alpha = 0.5
    }
}
