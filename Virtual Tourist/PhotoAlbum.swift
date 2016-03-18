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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    
    var annotation: MKAnnotation!
    var region: MKCoordinateRegion!
    var bbox : String = ""
    var pin : Pin!
    var images = [Image]()
    
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
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        label.hidden = true
        
        collectionButton.enabled = false;
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        self.mapView.centerCoordinate = annotation.coordinate
        
//        if pin!.photos.isEmpty {
            FlickrClient.sharedInstance().getImageFromFlickrBySearch(bbox) { (success, results, errorString) in
                if success {
                    for (photo) in results {
                        
                        let imageUrlString = photo["url_m"] as? String
                        let imageURL = NSURL(string: imageUrlString!)
                        let imageData = NSData(contentsOfURL: imageURL!)
                        let image = UIImage(data: imageData!)
                        let newPhoto = Image(image: image!)
                        self.images.append(newPhoto)
                        
                        _ = results.map() { (dictionary: [String : AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                            
//                            photo.pins = self.pin
                            
                            return photo
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView?.reloadData()
                            self.collectionButton.enabled = true
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.label.text = errorString
                        self.label.hidden = false
                        self.collectionButton.enabled = true
                    }
                    
                }
            }
//        }
    }
    
    // MARK: Core Data
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CollectionViewCell
        
//        cell.imageView.image = UIImage(named: "placeholder")
        
        let photo = images[indexPath.item]
        let photoImageView = UIImageView(image: photo.image)
//        photoImageView.contentMode = UIViewContentMode.Redraw
        cell.imageView.image = photoImageView.image
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print ("number of images: \(images.count)")
        return images.count
    }
    
    @IBAction func newCollection(sender: AnyObject) {
        print("adding new collection...")
//        FlickrClient.sharedInstance().getImageFromFlickrBySearch(bbox)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
