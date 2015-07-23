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
    
    // MARK: - IBOutlet properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - UIViewController methods override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationDirector = CLLocationManager()
        self.locationDirector.delegate = self
        self.locationDirector.desiredAccuracy = kCLLocationAccuracyBest
        self.locationDirector.requestWhenInUseAuthorization()
        self.locationDirector.pausesLocationUpdatesAutomatically = true
        self.locationDirector.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        let longPressAction = UILongPressGestureRecognizer(target: self, action: "executeLongPressAction:")
        longPressAction.minimumPressDuration = 2.0
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
        let latitudeDelta: CLLocationDegrees = 0.01
        let longitudeDelta: CLLocationDegrees = 0.01
        let userLocationSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let userLocationRegion = MKCoordinateRegionMake(userLocationCoordinate, userLocationSpan)
        self.mapView.setRegion(userLocationRegion, animated: true)
    }
    
    // MARK: - Local methods
    
    func executeLongPressAction(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let locationInViewUserTapsOn = gestureRecognizer.locationInView(self.mapView)
            let mapCoordinateFromViewCoordinate = self.mapView.convertPoint(locationInViewUserTapsOn, toCoordinateFromView: self.mapView)
            
//            // annotation 
//            
//            let userLocationAnnotation = MKPointAnnotation()
//            userLocationAnnotation.coordinate = mapCoordinateFromViewCoordinate
//            userLocationAnnotation.title = "Memorable place?"
//            userLocationAnnotation.subtitle = "Mark it as such if it is."
//            self.mapView.addAnnotation(userLocationAnnotation)
            
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
                        pointAnnotationMainTitle = "Added \(NSDate())"
                    }
                    pointAnnotationMainTitle = "\(subThoroughfare) \(thoroughfare)"
                    pointAnnotationSubTitle = "\(poi.subAdministrativeArea), \(poi.administrativeArea) \(poi.postalCode). \(poi.country)."
                }
                
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

