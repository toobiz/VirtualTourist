//
//  PhotoAlbum.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 10.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbum: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    
    var annotation: MKAnnotation!
    var region: MKCoordinateRegion!
    var bbox : String = ""
    var pin : Pin!
    
    func setMapViewAnnotation(annotation: MKAnnotation) {
        self.annotation = annotation
    }
    
    func setRegionForView(region: MKCoordinateRegion) {
        self.region = region
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photo Album"
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        removeButton.hidden = true
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
        // load saved pins
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        label.hidden = true
        
        collectionButton.enabled = false;
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        self.mapView.centerCoordinate = annotation.coordinate
        
        if pin.photos.isEmpty {
        downloadPhotos()
        } else {
            self.collectionButton.enabled = true
        }
    }
    
    func downloadPhotos() {
        
        FlickrClient.sharedInstance().getImageFromFlickrBySearch(bbox) { (success, results, error) in
            
            if let error = error {
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    self.label.hidden = false
                    self.label.text = error
                }
            } else {
                if let photoDictionaries = results as? [[String : AnyObject]] {
                    print(photoDictionaries)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Parse the array of movies dictionaries
                        _ = photoDictionaries.map() { (dictionary: [String : AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            photo.pin = self.pin
                            CoreDataStackManager.sharedInstance().saveContext()
                            self.collectionView?.reloadData()
                            return photo
                        }
                    }
                }
            }
        }
        self.collectionButton.enabled = true
    }
    
    // MARK: Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // MARK: CollectionView
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)

        cell?.alpha = 0.5
        collectionButton.hidden = true
        removeButton.hidden = false
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        cell?.alpha = 1.0
        collectionButton.hidden = false
        removeButton.hidden = true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
     
        if (cell.selected) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1.0
        }
        
        return cell
    }
    
    func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        var photoImage = UIImage()
        
        // Load photo
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Set the photo image
        if photo.imagePath == nil || photo.imagePath == "" {
            photoImage = UIImage(named: "placeholder")!
            print("Image not available")
            
        } else if photo.image != nil {
            photoImage = photo.image!
            print("Image retrieved from cache")
        } else {
            
            let task = FlickrClient.sharedInstance().taskForImageWithSize(photo.imagePath!) { imageData, error in
                
                if let error = error {
                    photoImage = UIImage(named: "placeholder")!
                    print("Image download error")
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView.image = photoImage
                        
                    }
                }
                
                if let data = imageData {
                    print("Image download successful")
                    photoImage = UIImage(data: data)!
                    dispatch_async(dispatch_get_main_queue()) {
                        photo.image = photoImage
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = photoImage
                    }
                }
                
            }
            
        }
        
        cell.imageView!.image = photoImage
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print ("number of images: \(images.count)")
        return pin.photos.count
            //images.count
    }
    
    @IBAction func newCollection(sender: AnyObject) {
        print("adding new collection...")
        pin.photos.removeAll()
        collectionView.reloadData()
        //        donwloadPhotos()
        CoreDataStackManager.sharedInstance().saveContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helpers
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

}
