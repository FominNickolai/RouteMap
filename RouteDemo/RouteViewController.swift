//
//  RouteViewController.swift
//  RouteDemo
//
//  Created by Simon Ng on 8/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    private var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation(sender:)))
        longpressGestureRecognizer.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longpressGestureRecognizer)
        
    }
    
    //Pin Location
    func pinLocation(sender: UILongPressGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        
        //Get the location of the touch
        let tappedPoint = sender.location(in: mapView)
        //Convert point to coordinate
        let tappedCoordinate = mapView.convert(tappedPoint, toCoordinateFrom: mapView)
        
        //Annotate on the map view
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        
        //Store the annotation for later use
        annotations.append(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
    
    //Action
    @IBAction func drawPolyline() {
        mapView.removeOverlays(mapView.overlays)
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
            let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
            mapView.add(polyline)
        }
    }
    

    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let annotationView = views[0]
        let endFrame = annotationView.frame
        annotationView.frame = endFrame.offsetBy(dx: 0, dy: -600)
        UIView.animate(withDuration: 0.3) {
            annotationView.frame = endFrame
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.lineWidth = 3.0
        render.strokeColor = .purple
        render.alpha = 0.5
        let visibleMapRect = mapView.mapRectThatFits(render.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        return render
    }
}


























