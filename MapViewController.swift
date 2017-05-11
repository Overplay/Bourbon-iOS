//
//  MapViewController.swift
//  Belashi-iOS
//
//  Created by Noah on 8/4/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftyJSON

class MapViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var annotations = [MKAnnotation]()
    
    var currentLocation: CLLocation!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let recenterBarButton = UIBarButtonItem(title: "Recenter", style: .plain, target: self, action: #selector(recenter))
        self.navigationItem.rightBarButtonItem = recenterBarButton
        
        self.mapView.delegate = self
        
        nc.addObserver(self, selector: #selector(getAndPlaceVenues), name: NSNotification.Name(rawValue: ASNotification.networkChanged.rawValue), object: nil)
        
        self.getAndPlaceVenues()
    }
    
    /// Makes a call to find all current venues and places them on the map.
    func getAndPlaceVenues() {
        StateController.sharedInstance.findAllVenues()
            .then { _ in
                self.placeVenues(StateController.sharedInstance.allVenues)
            }
            .catch { _ in
                log.error("Error getting venues")
            }
    }
    
    /// Creates an `MKPointAnnotation` for each venue and places them on the map.
    ///
    /// - Parameter venues: a list of `OGVenue` objects
    func placeVenues(_ venues: [OGVenue]) {
        
        // clear all current annotations or we will get duplicates
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // get current annotations and add to map
        for venue in venues {
            let geocoder: CLGeocoder = CLGeocoder()
            
            // Convert address into coordinates for visual map items
            geocoder.geocodeAddressString(venue.address, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
                
                guard let pmrks = placemarks else {
                    log.error("Not able to find any placemarks for venue \(venue.name)")
                    return
                }
                
                if ((pmrks.count) > 0) {
                    let topResult: CLPlacemark = (pmrks[0])
                    let placemark = MKPlacemark(placemark: topResult)
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = placemark.coordinate
                    pointAnnotation.title = venue.name
                    pointAnnotation.subtitle = venue.address
                    self.mapView.addAnnotation(pointAnnotation)
                }
            })
        }
    }
    
    func recenter() {
        // Zoom in on current location
        // 0.3 is some number. The smaller it is, the smaller the frame (huh, makes sense right?)
        self.mapView.setRegion(MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.3, 0.3)), animated: true)
    }
}

extension MapViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.annotations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "OGMapItemCell") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "OGMapItemCell")
            cell?.backgroundColor = UIColor(white: 51/255, alpha: 1.0)
            cell?.textLabel?.textColor = UIColor.white
            cell?.detailTextLabel?.textColor = UIColor( white: 1.0, alpha: 0.7)
            cell?.textLabel?.font = UIFont(name: Style.regularFont, size: 15.0)
            cell?.detailTextLabel?.font = UIFont(name: Style.lightFont, size: 12.0)
        }
        
        let annotation = self.annotations[indexPath.row]
        
        
        cell!.textLabel!.text = annotation.title!
        
        if cell!.textLabel!.text! == "Current Location" {
            cell!.textLabel!.font = UIFont(name: Style.regularFont, size: 15.0)
            cell!.detailTextLabel!.font = UIFont(name: Style.lightFont, size: 12.0)
            cell!.detailTextLabel!.text = ""
        } else {
            cell!.textLabel!.font = UIFont(name: Style.regularFont, size: 15.0)
            cell!.detailTextLabel!.font = UIFont(name: Style.lightFont, size: 12.0)
            cell!.detailTextLabel!.text = annotation.subtitle!
        }
        
        return cell!
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // On select or deselect of row, select or deselect that pin (aka annotation)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let annotation = self.annotations[indexPath.row]
        if self.mapView.view(for: annotation)!.isSelected {
            self.mapView.deselectAnnotation(annotation, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }else {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    // When the map view updates the current location, update the class variable.
    // But only recenter it upon getting this location the very first time, hence,
    // currentLocation would be nil to start off. If the user moves around, we don't
    // want to just zoom them back in or they can't look around
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let shouldCenter = self.currentLocation == nil
        self.currentLocation = userLocation.location!
        if shouldCenter {
            recenter()
        }
    }
    
    // Requested when creating the pin (aka annotation) view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.title! != "Current Location" {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "OurglasserPin")
            pinAnnotationView.animatesDrop = true
            // This is the green color RGB for Ourglass logo
            pinAnnotationView.pinTintColor = UIColor(red: (57.0/255.0), green: (172.0/255.0), blue: (72.0/255.0), alpha: 1.0)
            pinAnnotationView.canShowCallout = true
            // Make clickable
            let button = UIButton(type: .detailDisclosure)
            pinAnnotationView.rightCalloutAccessoryView = button
            return pinAnnotationView
        }else {
            return nil
        }
    }
    
    // Link deselection of pin (aka annotation) to table view
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let annotation = view.annotation!
        let index = self.annotations.index(where: {
            $0.title! == annotation.title!
        })!
        self.tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
    }
    
    // Link selection of pin (aka annotation) to table view
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation!
        let index = self.annotations.index(where: {
            $0.title! == annotation.title!
        })!
        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
    }
    
    // If the region changes, we want to remove what's in the table view
    // For one, if you try to open an annotation view that isn't on screen,
    // it crashes. But also it helps the user to see what's around them, and
    // if they zoom out, they can see more. You can make this zoom out to fit
    // if the annotation isn't in view if you want, but I thought this worked nicely.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Order annotations by distance from user
        let visibleAnnotations = (Array(self.mapView.annotations(in: self.mapView.visibleMapRect)) as NSArray) as! [MKAnnotation]
        self.annotations = [MKAnnotation]()
        self.annotations = visibleAnnotations.sorted(by: { (ann1: MKAnnotation, ann2: MKAnnotation) -> Bool in
            // Always order Current Location first
            // Also, if currentLocation isn't set yet, it will crash trying to determine distance, obviously.
            // This method is called once when location is found beacuse map recents and the region changes, so
            // the list will reload anyways.
            if ann1.title! == "Current Location" || self.currentLocation == nil {
                return true
            }
            let coordLoc1 = CLLocation(latitude: ann1.coordinate.latitude, longitude: ann1.coordinate.longitude)
            let dist1 = self.currentLocation.distance(from: coordLoc1)
            let coordLoc2 = CLLocation(latitude: ann2.coordinate.latitude, longitude: ann2.coordinate.longitude)
            let dist2 = self.currentLocation.distance(from: coordLoc2)
            return dist1 < dist2
        })
        self.tableView.reloadData()
    }
    
    // Order annotations when they are first added to map
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        // Order annotations by distance from user
        let visibleAnnotations = (Array(self.mapView.annotations(in: self.mapView.visibleMapRect)) as NSArray) as! [MKAnnotation]
        self.annotations = [MKAnnotation]()
        self.annotations = visibleAnnotations.sorted(by: { (ann1: MKAnnotation, ann2: MKAnnotation) -> Bool in
            if ann1.title! == "Current Location" || self.currentLocation == nil {
                return true
            }
            let coordLoc1 = CLLocation(latitude: ann1.coordinate.latitude, longitude: ann1.coordinate.longitude)
            let dist1 = self.currentLocation.distance(from: coordLoc1)
            let coordLoc2 = CLLocation(latitude: ann2.coordinate.latitude, longitude: ann2.coordinate.longitude)
            let dist2 = self.currentLocation.distance(from: coordLoc2)
            return dist1 < dist2
        })
        self.tableView.reloadData()
    }
    
    // Open in apple maps! My favorite...
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Make restaurant map item
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving])
    }
    
}
