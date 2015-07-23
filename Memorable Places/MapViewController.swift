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
        if selectedAddress == 0 {
            self.locationDirector.requestWhenInUseAuthorization()
            self.locationDirector.startUpdatingLocation()
        }
        else {
            let selectedAddressLatitude: CLLocationDegrees = Double(placesOfInterest[selectedAddress]["latitude"]!)!
            let selectedAddressLongitude: CLLocationDegrees = NSString(string: placesOfInterest[selectedAddress]["longitude"]!).doubleValue
            let latitudeDeltaZoomLevel: CLLocationDegrees = self.mapCoordinateZoomLevel
            let longtitudeDeltaZoomLevel: CLLocationDegrees = self.mapCoordinateZoomLevel
            let areaSpannedByMapRegion: MKCoordinateSpan = MKCoordinateSpanMake(latitudeDeltaZoomLevel, longtitudeDeltaZoomLevel)
            let geographicalCoordiateStruct: CLLocationCoordinate2D = CLLocationCoordinate2DMake(selectedAddressLatitude, selectedAddressLongitude)
            let mapRegionToDisplay: MKCoordinateRegion = MKCoordinateRegionMake(geographicalCoordiateStruct, areaSpannedByMapRegion)
            self.mapView.setRegion(mapRegionToDisplay, animated: true)
            
            let userLocationAnnotation = MKPointAnnotation()
            userLocationAnnotation.coordinate = geographicalCoordiateStruct
            userLocationAnnotation.title = placesOfInterest[selectedAddress]["locationMainTitle"]
            userLocationAnnotation.subtitle = placesOfInterest[selectedAddress]["locationSubTitle"]
            self.mapView.addAnnotation(userLocationAnnotation)
        }
        self.mapView.showsUserLocation = true
        
        let longPressAction = UILongPressGestureRecognizer(target: self, action: "executeLongPressAction:")
        longPressAction.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        let userLocation = locations[0] as! CLLocation
        let userLocationCoordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        let latitudeDelta: CLLocationDegrees = self.mapCoordinateZoomLevel
        let longitudeDelta: CLLocationDegrees = self.mapCoordinateZoomLevel
        let userLocationSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let userLocationRegion = MKCoordinateRegionMake(userLocationCoordinate, userLocationSpan)
        self.mapView.setRegion(userLocationRegion, animated: true)
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
                    }
                    else if poi.subThoroughfare != nil {
                        subThoroughfare = poi.subThoroughfare
                    }
                    else if poi.thoroughfare != nil {
                        thoroughfare = poi.thoroughfare
                    }
                    else {
                        pointAnnotationMainTitle = "Added \(NSDate())."
                    }
                    pointAnnotationMainTitle = "\(subThoroughfare) \(thoroughfare)."
                    pointAnnotationSubTitle = "\(poi.subAdministrativeArea), \(poi.administrativeArea) \(poi.postalCode). \(poi.country)."
                }
                
                // assigning the location info into a var in table view controller
                placesOfInterest.append(["locationMainTitle":  "\(pointAnnotationMainTitle)", "locationSubTitle": "\(pointAnnotationSubTitle)", "latitude": "\(mapCoordinateFromViewCoordinate.latitude)", "longitude": "\(mapCoordinateFromViewCoordinate.longitude)"])
                
                // annotation
                
                let userLocationAnnotation = MKPointAnnotation()
                userLocationAnnotation.coordinate = mapCoordinateFromViewCoordinate
                userLocationAnnotation.title = pointAnnotationMainTitle
                userLocationAnnotation.subtitle = pointAnnotationSubTitle
                self.mapView.addAnnotation(userLocationAnnotation)
            })
        }
        
    }

}

