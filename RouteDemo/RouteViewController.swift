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
    
    //Computing the direction between first and second points
    func drawDirection(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D) {
        //Create map items from coordinate
        let startPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        //Set the source and desctination of the route
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .automobile
        
        //Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (routeResponse, routeError) in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                return
            }
            let route = routeResponse.routes[0]
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
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
    
    @IBAction func drawRoute() {
        mapView.removeOverlays(mapView.overlays)
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        self.mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        var index = 0
        while index < (annotations.count - 1) {
            drawDirection(startPoint: annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
    }
    
    @IBAction func removeAnnotations() {
        //Remove annotations and overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        
        //Clear the annotation array
        annotations.removeAll()
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


























