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
    
    // MARK: - CLLocationManagerDelegate methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
        print(locations)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationDirector = CLLocationManager()
        self.locationDirector.delegate = self
        self.locationDirector.desiredAccuracy = kCLLocationAccuracyBest
        self.locationDirector.requestWhenInUseAuthorization()
        self.locationDirector.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

