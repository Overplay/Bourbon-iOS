//
//  CreateVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/3/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit

class CreateVenueViewController: AccountBaseViewController {
    
    let curLocStr = "Current location"
    
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
    
    var selectedYelpVenue: YelpVenue?
    
    // keep a reference to the text field delegates or they will get deallocated
    var textFieldDelegates = [CustomTextFieldDelegate]()
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        yelpSearchLocation.text = curLocStr
        yelpSearchLocation.textColor = useCurrentLocationButton.tintColor
    }
    
    @IBAction func yelpSearchTermEditingChanged(_ sender: Any) {
        checkReadyToYelp()
    }
    
    @IBAction func yelpSearchLocationEditingChanged(_ sender: Any) {
        yelpSearchLocation.textColor = UIColor.white
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
        findButton.isEnabled = true
        fadeIn(findButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldDelegates.append(contentsOf: [
            CustomTextFieldDelegate(venueName, isValid: isValidEntry),
            CustomTextFieldDelegate(address1, isValid: isValidEntry),
            CustomTextFieldDelegate(address2, isValid: { _ in return true}),
            CustomTextFieldDelegate(city, isValid: isValidEntry),
            CustomTextFieldDelegate(state, isValid: isValidEntry),
            CustomTextFieldDelegate(zip, isValid: isValidEntry)
        ])
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            let yelpVenuesVC = navVC.viewControllers.first as! FindYelpVenuesViewController
            
            // TODO: actually do this
            if let loc = self.yelpSearchLocation.text, loc == curLocStr {
                yelpVenuesVC.searchLat = 35.2828752
                yelpVenuesVC.searchLong = -120.659616
            } else {
                yelpVenuesVC.searchLocation = self.yelpSearchLocation.text
            }
            
            yelpVenuesVC.searchTerm = self.yelpSearchTerm.text
            yelpVenuesVC.yelpVenueDelegate = self
        }
    }
    
    func isValidEntry(_ entry: String?) -> Bool {
        if entry != nil && entry != "" {
            return true
        }
        return false
    }
}

extension CreateVenueViewController: FindYelpVenuesDelegate {
    func selectYelpVenue(_ venue: YelpVenue) {
        self.venueName.text = venue.name
        self.address1.text = venue.address1
        self.address2.text = venue.address2
        self.city.text = venue.city
        self.state.text = venue.state
        self.zip.text = venue.zip
        self.selectedYelpVenue = venue

        // TODO: call text field delegate methods to check validity
    }
}

