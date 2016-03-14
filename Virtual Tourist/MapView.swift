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
import CoreData

class ViewController: UIViewController, MKMapViewDelegate {

    let savedLongitudeSpan = "Saved Longitude Span"
    let savedLatitudeSpan = "Saved Latitude Span"
    let savedLatitude = "Saved Latitude"
    let savedLongitude = "Saved Longitude"
    let locationManager = CLLocationManager()
    var editMode = Bool()
    var pins: [Pin]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        editMode = false
        
        mapView.addAnnotations(fetchAllPins())
        plainView()
        initMap()
        initGestureRecognizer()
    }
        
    // MARK: Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [Pin]()
        }
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
        longTap.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longTap)
    }
    
    func addPin(gestureRecognizer:UIGestureRecognizer) {
        let tapPoint = gestureRecognizer.locationInView(mapView)
        let tapLocation = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        if UIGestureRecognizerState.Began == gestureRecognizer.state {
            
            let pin = Pin(annotationLatitude: tapLocation.latitude, annotationLongitude: tapLocation.longitude, context: sharedContext)
//
            mapView.addAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()

        print("adding annotation")
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
        pinView?.animatesDrop = true
//        pinView?.draggable = true
        return pinView
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
            let pin = view.annotation as! Pin
            sharedContext.deleteObject(pin)
            mapView.removeAnnotation(pin)
            CoreDataStackManager.sharedInstance().saveContext()
            print("removing annotation")
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
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

