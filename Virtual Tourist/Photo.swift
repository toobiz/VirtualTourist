//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 16.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
class Photo : NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let ImagePath = "url_m"
        static let Name = "title"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String?
    @NSManaged var name: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        imagePath = dictionary[Keys.ImagePath] as? String
        id = Int((dictionary[Keys.ID] as? String)!)!
        name = dictionary[Keys.Name] as! String
    }
    
    var image: UIImage? {
        
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}
