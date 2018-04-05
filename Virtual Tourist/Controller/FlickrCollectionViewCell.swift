//
//  FlickrCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/28/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit
import CoreData
let imageCache = NSCache<NSString, UIImage>()

class FlickrCollectionViewCell: UICollectionViewCell {
    // Properties
    
    @IBOutlet weak var flickrImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Get the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    //var photoCD : PhotosCD!
    
    //FetechRequestController
    var fetchedhResultController = NSFetchedResultsController<NSFetchRequestResult>()
    var flickerData = FlickerClient.sharedInstance()
    
    func setPhotoCellWith(photo : PhotosCD) {
        DispatchQueue.main.async {
            if let url = photo.photoURLCD {
                self.loadImageUsingCacheWithURLString(url, photo, placeHolder: nil)
            }
        }
    }
}

extension FlickrCollectionViewCell: NSFetchedResultsControllerDelegate {
    func loadImageUsingCacheWithURLString(_ URLString : String, _ photoCD : PhotosCD, placeHolder : UIImage? ) {
        self.flickrImage?.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string : URLString)) {
            self.activityIndicator.stopAnimating()
            self.flickrImage.alpha = 1
            self.flickrImage?.image = cachedImage
            return
        } else {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageCD")
            fr.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
            let pred = NSPredicate(format: "photo == %@", argumentArray: [photoCD])
            fr.predicate = pred
            do {
                let object = try self.delegate.stack.context.fetch(fr) as? [ImageCD]
                if (object?.count)! > 0 {
                    if let img = (UIImage(data: object?.first?.imageCD! as! Data)) {
                        self.flickrImage?.image = img
                        self.activityIndicator.stopAnimating()
                        self.flickrImage.alpha = 1
                        return
                    }
                }
                
            } catch let err {
                print("Error in loading image from core data \(err.localizedDescription)")
            }
            
        }
        if let url = URL(string : URLString) {
            
            flickerData.loadImage(url) { (image) in
                performUIUpdatesOnMain {
                    imageCache.setObject(image, forKey: NSString(string : URLString))
                    self.activityIndicator.stopAnimating()
                    self.flickrImage.alpha = 1
                    self.flickrImage?.image = image
                }
                self.savePhoto(image: image, photoCD: photoCD)
            }
        }
    }
    
    // MARK : Save to Core data
    func savePhoto(image : UIImage, photoCD : PhotosCD) {
        // Save data retrieved from Network into Core Data
        if let imageEntity = NSEntityDescription.insertNewObject(forEntityName: "ImageCD", into: (self.delegate.stack.context)) as? ImageCD {
            imageEntity.imageCD = UIImagePNGRepresentation(image) as NSData?
            imageEntity.photo = photoCD
        }
        self.delegate.stack.saveContext()
    }
}
