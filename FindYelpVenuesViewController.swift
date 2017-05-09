//
//  FindYelpVenuesViewController.swift
//  Bourbon-iOS
//
//  Created by Alyssa Torres on 5/4/17.
//  Copyright © 2017 Ourglass. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol FindYelpVenuesDelegate {
    /// Delegate method called when a `YelpVenue` is selected.
    ///
    /// - Parameter venue: the selected venue
    func selectYelpVenue(_ venue: YelpVenue)
}

class FindYelpVenuesViewController: UIViewController {
    
    var yelpVenueDelegate: FindYelpVenuesDelegate?
    
    var searchLocation: String?
    var searchLat: Double?
    var searchLong: Double?
    var searchTerm: String?
    
    var yelpVenues = [YelpVenue]()
    var hasLoadedData = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var yelpTableView: UITableView! {
        didSet {
            yelpTableView.dataSource = self
            yelpTableView.delegate = self
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        yelpTableView.tableFooterView = UIView(frame: .zero)
        
        if let term = searchTerm {
            
            if let loc = searchLocation {
                activityIndicator.startAnimating()
            
                Asahi.sharedInstance.yelpSearch(location: loc, term: term)
                    .then { response -> Void in
                        self.yelpVenues = self.processYelpVenues(response)

                    }.catch { error in
                        log.error(error)
     
                    }.always {
                        self.activityIndicator.stopAnimating()
                        self.hasLoadedData = true
                        self.yelpTableView.reloadData()
                }
                
            } else if let lat = searchLat, let lng = searchLong {
                activityIndicator.startAnimating()
                
                Asahi.sharedInstance.yelpSearch(latitude: lat, longitude: lng, term: term)
                    .then { response -> Void in
                        self.yelpVenues = self.processYelpVenues(response)
                        
                    }.catch { error in
                        log.error(error)
                        
                    }.always {
                        self.activityIndicator.stopAnimating()
                        self.hasLoadedData = true
                        self.yelpTableView.reloadData()
                }
                
            } else {
                hasLoadedData = true
            }
            
        } else {
            hasLoadedData = true
        }
    }
    
    func processYelpVenues(_ inboundVenueJson: JSON) -> [YelpVenue] {
        var venues = [YelpVenue]()
        
        guard let venueJsonArr = inboundVenueJson["businesses"].array else {
            return venues
        }
        
        for venue in venueJsonArr {
            do {
                try venues.append(YelpVenue(venue))
            } catch YelpError.badJson {
                log.debug("got a bad yelp venue json")
            } catch {
                log.debug("error parsing yelp venue")
            }
        }
        return venues
    }
}

extension FindYelpVenuesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = yelpVenues.count
        
        if rows == 0 && self.hasLoadedData { // no data and we have already loaded
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "It looks like there are no results!"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont(name: Style.regularFont, size: 12.0)
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
            
        } else if rows == 0 { // no data but we are loading
            tableView.separatorStyle = .none
            
        } else { // we have data
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let venue = yelpVenues[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: YelpTableViewCell.identifier, for: indexPath) as! YelpTableViewCell
        
        cell.name.text = venue.name
        cell.address.text = venue.address
        cell.distance.text = venue.distance
        cell.venueImage.setImageFromURL(venue.imageUrl)
        
        return cell
    }
}

extension FindYelpVenuesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = self.yelpVenueDelegate {
            delegate.selectYelpVenue(self.yelpVenues[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
