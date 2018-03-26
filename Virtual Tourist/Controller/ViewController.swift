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
    
    // Properties
    var cordinates = CLLocationCoordinate2D()
    let flickerConnect = FlickerClient.sharedInstance()
    
    // Get the stack
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    // FetechRequestController
    
    // MARK: Properties
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: LocationCD.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitudeCD", ascending: false), NSSortDescriptor(key: "longitudeCD", ascending: false)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set MapView delegate
        mapView.delegate = self
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(longGesture)
    }


    @IBAction func addAnnotation( _ longGesture: UILongPressGestureRecognizer ) {
        
        let locationOnView = longGesture.location(in: mapView)
        cordinates = mapView.convert(locationOnView, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = cordinates
        mapView.addAnnotation(annotation)
        
        // Save to CareData
        saveLocationCD(cordinates.latitude, cordinates.longitude)
    }
}

// MARK : Navigation

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! FlickrCollectionViewController
        viewController.cordinates = self.cordinates
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {        
        self.performSegue(withIdentifier: "Pin", sender: self)
    }
}

// MARK : Coredata logic
extension ViewController {
    
    // Save data
    func saveLocationCD(_ latitude : Double, _ Longitude : Double) {
        let context = fetchedhResultController.managedObjectContext

        if let locationEntity = NSEntityDescription.insertNewObject(forEntityName: "LocationCD", into: context) as? LocationCD {
            locationEntity.latiduteCD = latitude
            locationEntity.longitudeCD = Longitude
            do {
                try context.save()
                executeSearch()
            } catch let error {
                print(error)
            }
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


