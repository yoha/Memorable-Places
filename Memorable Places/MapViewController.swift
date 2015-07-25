//
//  MapViewController.swift
//  Memorable Places
//
//  Created by Yohannes Wijaya on 7/21/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Stored Properties
    
    var locationDirector: CLLocationManager!
    let mapCoordinateZoomLevel: CLLocationDegrees = 0.01
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - UIViewController methods override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationDirector = CLLocationManager()
        self.locationDirector.delegate = self
        self.locationDirector.desiredAccuracy = kCLLocationAccuracyBest
        self.locationDirector.pausesLocationUpdatesAutomatically = true
        if selectedAddressIndex == -1 {
            self.locationDirector.requestWhenInUseAuthorization()
            self.locationDirector.startUpdatingLocation()
        }
        else {
            let userLocationLatitude: CLLocationDegrees = Double(placesOfInterest[selectedAddressIndex]["latitude"]!)!
            let userLocationLongitude: CLLocationDegrees = NSString(string: placesOfInterest[selectedAddressIndex]["longitude"]!).doubleValue
            self.setupUserLocationOnMap(userLocationLatitude, longitude: userLocationLongitude)
            
            let userLocationAnnotationMainTitle: String = placesOfInterest[selectedAddressIndex]["locationMainTitle"]!
            let userLocationAnnotationSubTitle: String = placesOfInterest[selectedAddressIndex]["locationSubTitle"]!
            setupUserLocationAnnotation(userLocationLatitude, longitude: userLocationLongitude, annotationMainTitle: userLocationAnnotationMainTitle, annotationSubTitle: userLocationAnnotationSubTitle)
        }
        self.mapView.showsUserLocation = true
        
        let longPressAction = UILongPressGestureRecognizer(target: self, action: "executeLongPressAction:")
        longPressAction.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressAction)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setObject(placesOfInterest, forKey: "savedPlacesOfInterest")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let userLocation = locations[0] as! CLLocation
        self.setupUserLocationOnMap(userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    }
    
    // MARK: - Local methods
    
    func executeLongPressAction(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let locationInViewUserTapsOn = gestureRecognizer.locationInView(self.mapView)
            let mapCoordinateFromViewCoordinate = self.mapView.convertPoint(locationInViewUserTapsOn, toCoordinateFromView: self.mapView)
            
            // address conversion
            
            let locationFromMapCoordinate = CLLocation(latitude: mapCoordinateFromViewCoordinate.latitude, longitude: mapCoordinateFromViewCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(locationFromMapCoordinate, completionHandler: { (placemarks, error) -> Void in
                var pointAnnotationMainTitle = ""
                var pointAnnotationSubTitle = ""
                if error != nil {
                    print(error)
                }
                else if let poi = CLPlacemark(placemark: placemarks![0] as CLPlacemark) {
                    var subThoroughfare = "", thoroughfare = ""
                    if poi.subThoroughfare != nil && poi.thoroughfare != nil {
                        subThoroughfare = poi.subThoroughfare
                        thoroughfare = poi.thoroughfare
                        pointAnnotationMainTitle = "\(subThoroughfare) \(thoroughfare)."
                    }
                    else if poi.thoroughfare != nil {
                        thoroughfare = poi.thoroughfare
                        pointAnnotationMainTitle = "\(thoroughfare)."
                    }
                    else {
                        pointAnnotationMainTitle = "Added \(NSDate())."
                    }
                    pointAnnotationSubTitle = "\(poi.subAdministrativeArea), \(poi.administrativeArea) \(poi.postalCode). \(poi.country)."
                }
                
                // assigning the location info into a var in table view controller
                
                placesOfInterest.append(["locationMainTitle":  "\(pointAnnotationMainTitle)", "locationSubTitle": "\(pointAnnotationSubTitle)", "latitude": "\(mapCoordinateFromViewCoordinate.latitude)", "longitude": "\(mapCoordinateFromViewCoordinate.longitude)"])
                
                // annotation
                
                self.setupUserLocationAnnotation(mapCoordinateFromViewCoordinate.latitude, longitude: mapCoordinateFromViewCoordinate.longitude, annotationMainTitle: pointAnnotationMainTitle, annotationSubTitle: pointAnnotationSubTitle)
                
            })
        }
        
    }
    
    func setupUserLocationOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let geographicalCoordinateStruct: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let latitudeDeltaZoomLevel: CLLocationDegrees = self.mapCoordinateZoomLevel
        let longitudeDeltaZoomLevel: CLLocationDegrees = self.mapCoordinateZoomLevel
        let areaSpannedByMapRegion: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDeltaZoomLevel, longitudeDeltaZoomLevel)
        let mapRegionToDisplay: MKCoordinateRegion = MKCoordinateRegionMake(geographicalCoordinateStruct, areaSpannedByMapRegion)
        self.mapView.setRegion(mapRegionToDisplay, animated: true)
    }
    
    func setupUserLocationAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, annotationMainTitle: String, annotationSubTitle: String) {
        let userLocationAnnotation = MKPointAnnotation()
        userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        userLocationAnnotation.title = annotationMainTitle
        userLocationAnnotation.subtitle = annotationSubTitle
        self.mapView.addAnnotation(userLocationAnnotation)
        self.mapView.selectAnnotation(userLocationAnnotation, animated: true)
    }
    

}

