//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 08.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    let savedLongitudeSpan = "Saved Longitude Span"
    let savedLatitudeSpan = "Saved Latitude Span"
    let savedLatitude = "Saved Latitude"
    let savedLongitude = "Saved Longitude"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        plainView()
        
//        let longitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitudeSpan)
//        let latitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitudeSpan)
//        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitude)
//        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitude)
//        
//        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
//        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let region = MKCoordinateRegionMake(location, span)
//        
//        mapView.setRegion(region, animated: false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let longitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitudeSpan)
        let latitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitudeSpan)
        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitude)
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitude)
        
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: false)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        print("Longitude: \(mapView.region)")
        
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: savedLongitudeSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: savedLatitudeSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: savedLongitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: savedLatitude)
    }

    // MARK: UI Configuration
    
    func editView() {
        toolbar.hidden = false
        let editButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "plainView")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func plainView() {
        toolbar.hidden = true
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editView")
        self.navigationItem.rightBarButtonItem = editButton
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

