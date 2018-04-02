//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/26/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class ViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    var cordinates = CLLocationCoordinate2D()
    
     //Get the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
     //FetechRequestController
    
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: LocationCD.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latiduteCD", ascending: false), NSSortDescriptor(key: "longitudeCD", ascending: false)]
        let context = delegate.stack.context
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        executeSearch()
        
        //Set MapView delegate
        mapView.delegate = self
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longGesture)
        
        
        // Load Annotation on map
       
        for loc in fetchedhResultController.fetchedObjects as! [LocationCD] {
            loadAnnotation(loc.latiduteCD, long: loc.longitudeCD)
        }
    
    }

    // MARK : Add annotation
    
    func loadAnnotation(_ lat : Double, long : Double) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.addAnnotation(annotation)
        
    }
    
    @IBAction func addAnnotation( _ longGesture: UILongPressGestureRecognizer ) {
        
        let locationOnView = longGesture.location(in: mapView)
        cordinates = mapView.convert(locationOnView, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        mapView.addAnnotation(annotation)
        
        // Save to CareData
        //_ = LocationCD(latitude: cordinates.longitude, longitude: cordinates.longitude, context: delegate.stack.context)
        saveLocationCD(cordinates.latitude, cordinates.longitude)
    }
}

// MARK : Navigation

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! FlickrCollectionViewController
        //
        viewController.cordinates = self.cordinates // get this from fetchRequestController
        // Location object fetch request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        fr.sortDescriptors = [NSSortDescriptor(key: "latiduteCD", ascending: true)]
        
        // Predicate
        let predlat = NSPredicate(format: "latiduteCD == %f", argumentArray: [cordinates.latitude])
        //let predLon = NSPredicate(format: "longitudeCD == %f", argumentArray: [cordinates.longitude])
        fr.predicate = predlat
       // fr.predicate = predLon
        
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
        } catch {
            print("Error in fetching")
        }
        
        // Get LocationCD for tapped Annotation
        viewController.locationCD = frc.fetchedObjects?.first as! LocationCD
        
        // Create FetechRequestCortroller for LocationCD
        let frPhotos = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotosCD")
        frPhotos.sortDescriptors = [NSSortDescriptor(key: "photoURLCD", ascending: false)]
        let context = delegate.stack.context
        let pred = NSPredicate(format: "location == %@", argumentArray: [frc.fetchedObjects?.first as! LocationCD])
        frPhotos.predicate = pred
        let frcPhotos = NSFetchedResultsController(fetchRequest: frPhotos, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        // Pass frc and LocationCD to next viewcontroller
        viewController.fetchedhResultController = frcPhotos
       
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        cordinates = (view.annotation?.coordinate)!
        self.performSegue(withIdentifier: "Pin", sender: self)
    }
}

// MARK : Coredata logic
extension ViewController {
    
    // Save data
    func saveLocationCD(_ latitude : Double, _ Longitude : Double) {
        let context = delegate.stack.context
        if let locationEntity = NSEntityDescription.insertNewObject(forEntityName: "LocationCD", into: context) as? LocationCD {
            locationEntity.latiduteCD = latitude
            locationEntity.longitudeCD = Longitude
                delegate.stack.saveContext()
                executeSearch()
        }
    }
    
    // Fetch data
    func executeSearch() {
        do {
            try fetchedhResultController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedhResultController)")
        }
    }
}


