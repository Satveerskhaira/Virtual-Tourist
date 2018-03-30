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


class FlickrCollectionViewController: UIViewController,NSFetchedResultsControllerDelegate, MKMapViewDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollection: UIButton!
    
    // Properties
    
    var cordinates = CLLocationCoordinate2D()
    var flickerData = FlickerClient.sharedInstance()
    var locationData : Location?
    var countOfSetions = 0
    var locationCD : LocationCD!
    //Get the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    //FetechRequestController
    
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: PhotosCD.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoURLCD", ascending: false)]
        let context = delegate.stack.context
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
       // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Setup map
        let region = MKCoordinateRegionMake(cordinates, MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        mapView.addAnnotation(annotation)
        
        // Fetch Photo data
        executeSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        // Fetch data
        if fetchedhResultController.fetchedObjects == nil {
            loadData(false, cordinates.latitude, cordinates.longitude) { (location) in
                self.locationData = location!
                self.countOfSetions = (self.locationData?.photo?.count)!
                
                // Update on main thread
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        }
        
    }
    
    @IBAction func reloadData(_ sender: Any) {
        if newCollection.titleLabel?.text == "NewCollection" {
            
        } else {
            
        }
    }
    
}

// MARK : Delegete and Datasource for UICollectionView

extension FlickrCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countOfSetions
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FlickrCollectionViewCell        
        let imageURL = URL(string: (locationData?.photo?[indexPath.row].url)!)!
        cell.activityIndicator.startAnimating()
        // Download image from network
        flickerData.loadImage(imageURL) { (image) in
            performUIUpdatesOnMain {
                cell.activityIndicator.stopAnimating()
                cell.flickrImage.image = image
            }
        }
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.layer.borderColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8).cgColor
//        return true
//    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8).cgColor
        if (cell?.isHighlighted)! {
            cell?.isHighlighted = false
            return false
        } else {
                cell?.isHighlighted = true  
                return true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    

}

// MARK : Core Data fetch for mapview
extension FlickrCollectionViewController  {
    // Fetch data
    func executeSearch() {
        do {
            try fetchedhResultController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedhResultController)")
        }
    }
}

//
// MARK : Data load from Network or core data

extension FlickrCollectionViewController {
    
    // Reload data from Network
    
    // Load data from Network or coredata
    func loadData(_ callType : Bool, _ latidute : Double, _ longitude : Double, handler : @escaping (_ locationData : Location?) -> Void) {
        var perform = false
        
        for a in flickerData.store {
            if a == Location(latidute: latidute, longitude: longitude, photo: nil) {
                if callType == true {
                   // flickerData.store.
                }
                perform = true
                handler(a)
            }
        }
        
        if !perform {
            flickerData.searchImageWithLatAndLOn(flickerData.createParamtersForURL(latidute, longitude)) { (location, success, error) in
                guard (error == nil) else {
                    print(error!)
                    return
                }
                if success {
                    handler(location)
                }
            }
        }
    }
}

// MARK : Core Data
extension FlickrCollectionViewController {
    
    func savePhoto() {
        
    }
    
}
