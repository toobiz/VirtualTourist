//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 10.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit

@objc(Pin)
class Pin: NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }

    init(annotationLatitude: Double, annotationLongitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = NSNumber(double: annotationLatitude)
        longitude = NSNumber(double: annotationLongitude)

    }
}
