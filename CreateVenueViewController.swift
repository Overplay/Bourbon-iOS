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

protocol CreateVenueViewControllerDelegate {
    func createdVenue(_ venue: OGVenue)
}

class CreateVenueViewController: UITableViewController {
    
    var delegate: CreateVenueViewControllerDelegate?
    
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
    
    // keep a reference to the text field delegates or they will get deallocated
    var textFieldDelegates = [CustomTextFieldDelegate]()
    
    var selectedYelpVenue: YelpVenue?
    
    @IBAction func createVenue(_ sender: Any) {
        self.view.endEditing(true)
        createVenueButton.isEnabled = false
        createVenueButton.alpha = 0.5
        createVenueActivityIndicator.startAnimating()
        
        let uuid = "fake_uuid"
        
        // TODO: make API call and include yelpId if we have it
        
        guard let name = venueName.text, let addr1 = address1.text,
            let addr2 = address2.text, let city = city.text,
            let state = state.text, let zip = zip.text else {
                createVenueButton.isEnabled = true
                createVenueButton.alpha = 1.0
                createVenueActivityIndicator.stopAnimating()
                return
        }
        
        let venue = OGVenue(name: name, street: addr1 + " " + addr2, city: city, state: state, zip: zip, latitude: 0.0, longitude: 0.0, uuid: uuid)
        let geocoder = CLGeocoder()
            
        geocoder.geocodeAddressString(venue.address) { (placemarks, error) -> Void in
            guard let placemark = placemarks?.first,
                let coords = placemark.location?.coordinate else {
                    self.createVenueButton.isEnabled = true
                    self.createVenueButton.alpha = 1.0
                    self.createVenueActivityIndicator.stopAnimating()
                    return
            }
            venue.latitude = coords.latitude
            venue.longitude = coords.longitude
            
            if let del = self.delegate {
                del.createdVenue(venue)
                HUD.flash(.success, delay: 1.0)
                self.dismiss(animated: true, completion: nil)
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

