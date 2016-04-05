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

class PhotoAlbum: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var selectedItems = [NSIndexPath]()
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
        fetchedResultsController.delegate = self
        spinner.hidesWhenStopped = true
        
        let space: CGFloat = 1.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        let dimension = floor(self.view.frame.size.width / 3)
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        // load saved pins
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        spinner.startAnimating()
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        self.mapView.centerCoordinate = annotation.coordinate
        removeButton.hidden = true
        
        if pin.photos.isEmpty {
        downloadPhotos()
        } else {
            self.collectionButton.enabled = true
        }
    }
    
    func downloadPhotos() {
        self.spinner.startAnimating()
        
        FlickrClient.sharedInstance().getImageFromFlickrBySearch(bbox) { (success, results, error) in
            
            if let error = error {
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
//                    self.label.hidden = false
//                    self.label.text = error
                }
            } else {
                if let photoDictionaries = results as? [[String : AnyObject]] {
                    print(photoDictionaries)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Parse the array of photo dictionaries
                        _ = photoDictionaries.map() { (dictionary: [String : AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            photo.pin = self.pin
                            CoreDataStackManager.sharedInstance().saveContext()
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

            selectedItems.append(indexPath)
            print(selectedItems.count)
        
        buttons()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        cell?.alpha = 1.0

        if let index = selectedItems.indexOf(indexPath) {
            selectedItems.removeAtIndex(index)
        }
        print(selectedItems.count)
        
        buttons()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: CollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        var photoImage = UIImage(named: "placeholder")
        
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
            
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner.hidden = false
            }
            
            _ = FlickrClient.sharedInstance().taskForImageWithSize(photo.imagePath!) { imageData, error in
                
                if let _ = error {
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
        
            dispatch_async(dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos.count
    }
    
    // MARK: Function buttons
    
    @IBAction func newCollection(sender: AnyObject) {
        print("adding new collection...")

        let oldPhotos = fetchedResultsController.fetchedObjects as! [Photo]
        
        for photo in oldPhotos {
            sharedContext.deleteObject(photo)
            print("deleting all photos")
        }
        downloadPhotos()
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    @IBAction func removeItems(sender: AnyObject) {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedItems {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
            print("deleting selected photos")
        }
        
        selectedItems.removeAll()
        buttons()
        CoreDataStackManager.sharedInstance().saveContext()
        
        /* TODO:
        
        - alert view when no photos were found
        
        */
    }
    
    // MARK: NSFetchedResultsController
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView.reloadData()
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
    
    func buttons() {
        if selectedItems.count > 0 {
            removeButton.hidden = false
            collectionButton.hidden = true
        } else {
            removeButton.hidden = true
            collectionButton.hidden = false
        }
    }
}
