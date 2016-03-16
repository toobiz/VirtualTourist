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
        static let ImagePath = "image_path"
        static let Name = "name"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String
    @NSManaged var name: String
    @NSManaged var pins: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        id = dictionary[Keys.ID] as! Int
        imagePath = dictionary[Keys.ImagePath] as! String
        name = dictionary[Keys.Name] as! String
    }
}
