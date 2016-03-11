//
//  PhotoAlbum.swift
//  Virtual Tourist
//
//  Created by Michał Tubis on 10.03.2016.
//  Copyright © 2016 Weblify. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbum: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Photo Album"
        collectionView.delegate = self
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
//        let meme = memes[indexPath.item]
//        let imageView = UIImageView(image: "placeholder")
        print("hello!")
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    @IBAction func newCollection(sender: AnyObject) {
        print("adding new collection...")   
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
