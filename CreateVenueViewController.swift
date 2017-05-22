//
//  CreateVenueViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/3/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import CoreLocation
import PKHUD
import SwiftyJSON

class CreateVenueViewController: UITableViewController {
    
    let curLocStr = "Current location"
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    @IBOutlet weak var yelpSearchTerm: UITextField!
    @IBOutlet weak var yelpSearchLocation: UITextField!
    @IBOutlet weak var useCurrentLocationButton: UIButton! {
        didSet {
            useCurrentLocationButton.isEnabled = false
        }
    }
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var createVenueButton: UIButton!
    @IBOutlet weak var createVenueActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var venueName: UITextField!
    @IBOutlet weak var address1: UITextField!
    @IBOutlet weak var address2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    
    @IBOutlet weak var errorBlock: UIView!
    @IBOutlet weak var errorBlockLabel: UILabel!
    
    // keep a reference to the text field delegates or they will get deallocated
    var textFieldDelegates = [CustomTextFieldDelegate]()
    
    var selectedYelpVenue: YelpVenue?
    
    @IBAction func createVenue(_ sender: Any) {
        self.view.endEditing(true)
        errorBlock.isHidden = true
        createVenueButton.isEnabled = false
        createVenueButton.alpha = 0.5
        createVenueActivityIndicator.startAnimating()
        
        guard let name = venueName.text, isValidEntry(name),
            let addr1 = address1.text, isValidEntry(addr1),
            let addr2 = address2.text,
            let city = city.text, isValidEntry(city),
            let state = state.text, isValidEntry(state),
            let zip = zip.text, isValidEntry(zip) else {
                
                // highlight red any fields that were not valid
                for del in textFieldDelegates {
                    del.textFieldDidEndEditing(UITextField())
                }
                
                createVenueButton.isEnabled = true
                createVenueButton.alpha = 1.0
                createVenueActivityIndicator.stopAnimating()
                return
        }
        
        let venue = OGVenue(name: name,
                            street: addr1, street2: addr2,
                            city: city, state: state, zip: zip,
                            latitude: 0.0, longitude: 0.0, uuid: "")
        
        if let yv = selectedYelpVenue {
            venue.yelpId = yv.yelpId
        }
        
        let geocoder = CLGeocoder()
            
        geocoder.geocodeAddressString(venue.address) { (placemarks, error) -> Void in
            guard let placemark = placemarks?.first,
                let coords = placemark.location?.coordinate else {
                    
                    // unable to geocode this address, so we will show an error
                    self.address1.changeBorderColor(UIColor.red)
                    if addr2 != "" {
                        self.address2.changeBorderColor(UIColor.red)
                    }
                    self.city.changeBorderColor(UIColor.red)
                    self.state.changeBorderColor(UIColor.red)
                    self.zip.changeBorderColor(UIColor.red)
                    
                    self.errorBlockLabel.text = "Uh oh! It looks like the address you provided isn't valid."
                    self.errorBlock.isHidden = false
                    self.errorBlock.shake()
                    
                    self.createVenueButton.isEnabled = true
                    self.createVenueButton.alpha = 1.0
                    self.createVenueActivityIndicator.stopAnimating()
                    return
            }
            
            // we were able to geocode the address
            venue.latitude = coords.latitude
            venue.longitude = coords.longitude
            
            Asahi.sharedInstance.addVenue(venue: venue)
                
                .then { uuid -> Void in
                    venue.uuid = uuid
                    HUD.flash(.success, delay: 1.0)
                    _ = self.navigationController?.popViewController(animated: true)
                    
                }.catch { error -> Void in
                    
                    switch error {
                        
                    case AsahiError.authFailure:
                        self.errorBlockLabel.text = "Sorry, it looks like you aren't authorized to create a venue!"
                        self.errorBlock.isHidden = false
                        self.errorBlock.shake()
                        
                    case AsahiError.tokenInvalid: // this person needs to log back in
                        let alertController = UIAlertController(
                            title: "Uh oh!",
                            message: "It looks like your session has expired. Please log back in.",
                            preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            Asahi.sharedInstance.logout()
                            self.performSegue(withIdentifier: "fromAddVenueToRegistration", sender: nil)
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    default: // otherwise unable to add the venue
                        self.errorBlockLabel.text = "Oh no...it looks like something went wrong adding your venue."
                        self.errorBlock.isHidden = false
                        self.errorBlock.shake()
                    }
                    
                    self.createVenueButton.isEnabled = true
                    self.createVenueButton.alpha = 1.0
                    self.createVenueActivityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        yelpSearchLocation.text = curLocStr
        yelpSearchLocation.textColor = useCurrentLocationButton.tintColor
        checkReadyToYelp()
    }
    
    @IBAction func yelpSearchTermEditingChanged(_ sender: Any) {
        checkReadyToYelp()
    }
    
    @IBAction func yelpSearchTermNext(_ sender: Any) {
        yelpSearchLocation.becomeFirstResponder()
    }
    
    @IBAction func yelpSearchLocationEditingChanged(_ sender: Any) {
        yelpSearchLocation.textColor = UIColor.white
        checkReadyToYelp()
    }
    
    @IBAction func yelpSearchLocationNext(_ sender: Any) {
        self.view.endEditing(true)
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
        
        locationManager.delegate = self
        locationManager.requestLocation()
        
        textFieldDelegates.append(contentsOf: [
            CustomTextFieldDelegate(venueName, isValid: isValidEntry, inTableView: true),
            CustomTextFieldDelegate(address1, isValid: isValidEntry, inTableView: true),
            CustomTextFieldDelegate(address2, isValid: { _ in return true}, inTableView: true),
            CustomTextFieldDelegate(city, isValid: isValidEntry, inTableView: true),
            CustomTextFieldDelegate(state, isValid: isValidEntry, inTableView: true),
            CustomTextFieldDelegate(zip, isValid: isValidEntry, inTableView: true)
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
            
            if let loc = yelpSearchLocation.text, loc == curLocStr {
                if let curLoc = currentLocation {
                    yelpVenuesVC.searchLat = curLoc.coordinate.latitude
                    yelpVenuesVC.searchLong = curLoc.coordinate.longitude
                }
            } else {
                yelpVenuesVC.searchLocation = yelpSearchLocation.text
            }
            
            yelpVenuesVC.searchTerm = yelpSearchTerm.text
            yelpVenuesVC.yelpVenueDelegate = self
        }
    }
    
    func isValidEntry(_ entry: String?) -> Bool {
        if entry != nil && entry != "" {
            return true
        }
        return false
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

        for del in textFieldDelegates {
            del.textFieldDidEndEditing(UITextField())
        }
    }
}

extension CreateVenueViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
            self.useCurrentLocationButton.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("failed to find user's location: \(error.localizedDescription)")
    }
}

