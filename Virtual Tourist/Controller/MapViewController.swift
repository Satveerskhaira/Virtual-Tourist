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
class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePin: UILabel!
    
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
        longGesture.minimumPressDuration = 0.5
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
    
    
    @IBAction func addAnnotation( _ longGesture: UIGestureRecognizer ) {
        let locationOnView = longGesture.location(in: mapView)
        cordinates = mapView.convert(locationOnView, toCoordinateFrom: mapView)
        let oldAnnotations = mapView.annotations.filter({ (annotation) -> Bool in
            if annotation.coordinate.latitude == cordinates.latitude && annotation.coordinate.longitude == cordinates.longitude {
                return true
            } else {
                return false
            }
        })
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        mapView.removeAnnotations(oldAnnotations)
        mapView.addAnnotation(annotation)
        saveLocationCD(cordinates.latitude, cordinates.longitude)
        
    }
    
    @IBOutlet weak var deletePinButton: UIBarButtonItem!
    @IBAction func deletePinAction(_ sender: Any) {
        if deletePinButton.tag == 0 {
            deletePin.isHidden = false
            deletePinButton.title = "Done"
            deletePinButton.tag = 1
        } else {
            deletePin.isHidden = true
            deletePinButton.title = "Edit"
            deletePinButton.tag = 0
        }
        
    }
}

// MARK : Navigation

extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! FlickrCollectionViewController
        //
        viewController.cordinates = self.cordinates // get this from fetchRequestController
        // Location object fetch request
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        fr.sortDescriptors = [NSSortDescriptor(key: "latiduteCD", ascending: true)]
        
        // Predicate
        let predlat = NSPredicate(format: "latiduteCD == %f", argumentArray: [cordinates.latitude])
        fr.predicate = predlat
        
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try frc.performFetch()
        } catch let e as NSError{
            print("\(Constants.errorMessage.fetchResquestError) and error is \(e)")
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        cordinates = (view.annotation?.coordinate)!
        if deletePinButton.tag == 0 {
            self.performSegue(withIdentifier: "Pin", sender: self)
        } else {
            // Delete pin and remove from core data
            // Location object fetch request
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
            fr.sortDescriptors = [NSSortDescriptor(key: "latiduteCD", ascending: true)]
            // Predicate
            let predlat = NSPredicate(format: "latiduteCD == %f", argumentArray: [view.annotation?.coordinate.latitude])
            fr.predicate = predlat
            do {
                let objects = try delegate.stack.context.fetch(fr) as! [NSManagedObject]
                _ = objects.map{delegate.stack.context.delete($0)}
                
                delegate.stack.saveContext()
                
            } catch let e as NSError {
                print("\(Constants.errorMessage.fetchResquestError) and error is \(e)")
            }
            // Remove Annotation as well.
            mapView.removeAnnotation(view.annotation!)
            
        }
        
    }
}

// MARK : Coredata logic
extension MapViewController {
    
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
            print("\(Constants.errorMessage.fetchResquestError) and error is \(e)")
        }
    }
}


