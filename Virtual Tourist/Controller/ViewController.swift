//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/26/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    // Properties
    var cordinates = CLLocationCoordinate2D()
    let flickerConnect = FlickerClient.sharedInstance()
    
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



