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
    
    @IBOutlet weak var venueName: UITextField!
    @IBOutlet weak var address1: UITextField!
    @IBOutlet weak var address2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    
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
        let searchImage = #imageLiteral(resourceName: "ic_search_white_36pt")
        searchImageView.image = searchImage
        searchImageView.alpha = 0.6
        searchImageView.frame = CGRect(x: 5, y: 0, width: yelpSearchTerm.frame.height, height: yelpSearchTerm.frame.height)
        yelpSearchTerm.leftView = searchImageView
        yelpSearchTerm.leftViewMode = .always
        
        yelpSearchLocation.useCustomBottomBorder()
        let locationImageView = UIImageView()
        let locationImage = #imageLiteral(resourceName: "ic_location_on_white_36pt")
        locationImageView.image = locationImage
        locationImageView.alpha = 0.6
        locationImageView.frame = CGRect(x: 5, y: 0, width: yelpSearchLocation.frame.height, height: yelpSearchLocation.frame.height)
        yelpSearchLocation.leftView = locationImageView
        yelpSearchLocation.leftViewMode = .always
    }
}
