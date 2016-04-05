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
            let url = NSURL(fileURLWithPath: self.imagePath!)
            let fileName = url.lastPathComponent
            return FlickrClient.Caches.imageCache.imageWithIdentifier(fileName)
        }
        
        set {
            let url = NSURL(fileURLWithPath: self.imagePath!)
            let fileName = url.lastPathComponent
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: fileName!)
        }
    }
    override func prepareForDeletion() {
        
        //Delete the associated image file when the Photo managed object is deleted.
        if let imagePath = imagePath {
            if imagePath != "" {
                let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let pathArray = [dirPath, NSURL(fileURLWithPath: imagePath).lastPathComponent!]
                let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
                
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                    print("Photo deleted successfully")
                } catch {
                    print("Error when deleting photo")
                }
            }
        }
    }
}
