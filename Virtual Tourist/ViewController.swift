//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 08.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    let savedLongitudeSpan = "Saved Longitude Span"
    let savedLatitudeSpan = "Saved Latitude Span"
    let savedLatitude = "Saved Latitude"
    let savedLongitude = "Saved Longitude"
    let locationManager = CLLocationManager()
    var editMode = Bool()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        editMode = false
        
        plainView()
        initMap()
        initGestureRecognizer()
    }
    
    // MARK: Map Configuration
    func initMap() {
        let longitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitudeSpan)
        let latitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitudeSpan)
        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLongitude)
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(savedLatitude)
        
        if !(latitude == 0 && longitude == 0) {
            let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func initGestureRecognizer() {
        let longTap = UILongPressGestureRecognizer(target: self, action: "addPin:")
        longTap.minimumPressDuration = 1.0
        longTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(longTap)
    }
    
    func addPin(gestureRecognizer:UIGestureRecognizer) {
        gestureRecognizer.enabled = false
        let pin = gestureRecognizer.locationInView(mapView)
        let pinLocation : CLLocationCoordinate2D = mapView.convertPoint(pin, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pinLocation
        self.mapView.addAnnotation(annotation)
        print("adding annotation")
        gestureRecognizer.enabled = true
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        var i = -1;
        for view in views {
            i++;
            if view.annotation is MKUserLocation {
                continue;
            }
            
            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
                continue;
            }
            
            let endFrame:CGRect = view.frame;
            
            // Move annotation out of view
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height);
            
            // Animate drop
            let delay = 0.03 * Double(i)
            UIView.animateWithDuration(0.5, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations:{() in
                view.frame = endFrame
                // Animate squash
                }, completion:{(Bool) in
                    UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        view.transform = CGAffineTransformMakeScale(1.0, 0.6)
                        
                        }, completion: {(Bool) in
                            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                                view.transform = CGAffineTransformIdentity
                                }, completion: nil)
                    })
            })
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: savedLongitudeSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: savedLatitudeSpan)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.longitude, forKey: savedLongitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.center.latitude, forKey: savedLatitude)
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if editMode == false {
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        navigationItem.backBarButtonItem = backItem
        let photoAlbum = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbum") as! PhotoAlbum
        navigationController!.pushViewController(photoAlbum, animated: true)
            print("segueing to PhotoAlbum")
        } else {
            let pin = view.annotation
            mapView.removeAnnotation(pin!)
            print("removing annotation")
        }
    }

    // MARK: UI Configuration
    
    func editView() {
        editMode = true
        toolbar.hidden = false
        label.hidden = false
        let editButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "plainView")
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func plainView() {
        editMode = false
        toolbar.hidden = true
        label.hidden = true
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editView")
        self.navigationItem.rightBarButtonItem = editButton
    }

}

