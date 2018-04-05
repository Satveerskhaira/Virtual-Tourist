//
//  FlickrCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/28/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit
import MapKit
import CoreData
private let reuseIdentifier = "Cell"

class FlickrCollectionViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    // Properties
    var blockOperations = [BlockOperation]()
    var cordinates = CLLocationCoordinate2D()
    var flickerData = FlickerClient.sharedInstance()
    var locationCD : LocationCD!
    
    //Get the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    //FetechRequestController
    var fetchedhResultController = NSFetchedResultsController<NSFetchRequestResult>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.allowsMultipleSelection = true
        collectionView.dragInteractionEnabled = true
        self.newCollection.titleLabel?.text = "New Collection"
        
        
        // Setup map
        let region = MKCoordinateRegionMake(cordinates, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        mapView.addAnnotation(annotation)
        
        // Fetch Photo data
        fetchedhResultController.delegate = self
        executeSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch data
        if fetchedhResultController.fetchedObjects?.count == 0 {
            savePhoto()
        }
    }
    
    
    @IBAction func reloadData(_ sender: Any) {
        
        if newCollection.tag == 1 {
            newCollection.isEnabled = false
            deletePhoto(deleteAll: false)
            newCollection.titleLabel?.text = "Reload New Collection"
            newCollection.isEnabled = true
        } else {
            newCollection.isEnabled = false
            deletePhoto(deleteAll: true)
            newCollection.isEnabled = true
        }
    }
    
}

// MARK : Delegete and Datasource for UICollectionView

extension FlickrCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Cell load functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = fetchedhResultController.fetchedObjects?.count else {
            return 0
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlickrCollectionViewCell        
        // fetched data
        let photoData = fetchedhResultController.object(at: indexPath) as! PhotosCD
        cell.activityIndicator.startAnimating()
        // Download image from network
        cell.setPhotoCellWith(photo: photoData)
        return cell
    }
    
    
    // Cell change functions
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! FlickrCollectionViewCell
        cell.flickrImage.alpha = 0.2
        if (collectionView.indexPathsForSelectedItems?.count)! == 1 {
            self.newCollection.titleLabel?.text = "Remove Pictures"
            self.newCollection.tag = 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FlickrCollectionViewCell
        cell.flickrImage.alpha = 1
        if (collectionView.indexPathsForSelectedItems?.count)! == 0 {
            self.newCollection.titleLabel?.text = "Reload New Collection"
            self.newCollection.tag = 0
        }
    }
}

// MARK : Core Data fetch for mapview
extension FlickrCollectionViewController  {
    // Fetch data
    func executeSearch() {
        do {
            try fetchedhResultController.performFetch()
        } catch let e as NSError {
            print("\(Constants.errorMessage.fetchResquestError) and error is \(e)")
        }
    }
}

// MARK : Data load from Network or core data

extension FlickrCollectionViewController {
    
    // Reload data from Network
    
    // Load data from Network or coredata
    func loadData(_ latidute : Double, _ longitude : Double, handler : @escaping (_ locationDataPhotoArray : [Photo]?) -> Void) {
        flickerData.searchImageWithLatAndLOn(flickerData.createParamtersForURL(latidute, longitude)) { (locationPhotoArray, success, error) in
            guard (error == nil) else {
                print(error!)
                return
            }
            if success {
                handler(locationPhotoArray)
            }
        }
        
    }
}

// MARK : Core Data update
extension FlickrCollectionViewController {
    
    func savePhoto() {
        
        loadData(cordinates.latitude, cordinates.longitude) { (locationPhotoArray) in
            
            // Save data retrieved from Network into Core Data
            
            for locPho in locationPhotoArray! {
                if let photoEntity = NSEntityDescription.insertNewObject(forEntityName: "PhotosCD", into: (self.delegate.stack.context)) as? PhotosCD {
                    photoEntity.photoIDCD = locPho.id
                    photoEntity.photoURLCD = locPho.url
                    photoEntity.location = self.locationCD
                }
            }
            self.delegate.stack.saveContext()
        }
    }
    
    func deletePhoto( deleteAll : Bool) {
        // First retrive from core data
        executeSearch()
        
        let context = fetchedhResultController.managedObjectContext
        if deleteAll {
            _ = fetchedhResultController.fetchedObjects.map{$0.map{context.delete($0 as! NSManagedObject)}}
            delegate.stack.saveContext()
            savePhoto()
        } else {
            let indP = collectionView.indexPathsForSelectedItems
            let context = fetchedhResultController.managedObjectContext
            for a in indP! {
                let pho = fetchedhResultController.sections?[0].objects![(a.row)] as? NSManagedObject
                context.delete(pho!)
            }
            delegate.stack.saveContext()
        }
    }
    
}

// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension FlickrCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
            
        case .insert:
            self.blockOperations.append(BlockOperation(block: {
                self.collectionView.insertItems(at: [newIndexPath!])
            }))
            
        case .delete:
            self.blockOperations.append(BlockOperation(block: {
                self.newCollection.tag = 0
                self.collectionView.deleteItems(at: [indexPath!])
            }))
            
        case .update:
            
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.deleteItems(at: [indexPath!])
            collectionView.insertItems(at: [newIndexPath!])
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in blockOperations {
                operation.start()
            }
        }, completion: nil)
    }
}
