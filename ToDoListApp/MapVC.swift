//
//  MapVC.swift
//  ToDoListApp
//
//  Created by Austin Kim on 3/14/24.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routeText: UITextView!
    @IBOutlet weak var nearbyField: UITextField!
    
    var myMapView: MKMapView!;
    var myRouteText: UITextView!;
    var lon: Double = -1.0;
    var lat: Double = -1.0;
    
    var myLocMgr = CLLocationManager();
    var myGeoCoder = CLGeocoder();
    var placemarker: CLPlacemark?;
    
    func renderRoute() {
        let dirReq = MKDirections.Request();
        var myRoute: MKRoute?;
        var showRoute = self.routeText.text!;
        
        dirReq.source = MKMapItem.forCurrentLocation();
        dirReq.destination = MKMapItem(placemark: MKPlacemark(placemark: placemarker!));
        dirReq.transportType = .automobile;
        
        let myDirections = MKDirections(request: dirReq) as MKDirections;
        myDirections.calculate(completionHandler: {
            routeResponse, routeError in
            
            if routeError != nil{
                print("error");
                return;
            }
            
            myRoute = routeResponse?.routes[0] as MKRoute?;
            
            self.myMapView.removeOverlays(self.myMapView.overlays);
            self.myMapView.addOverlay((myRoute?.polyline)!, level:
                                        MKOverlayLevel.aboveRoads);
            
            let rec = myRoute?.polyline.boundingMapRect;
            self.myMapView.setRegion(MKCoordinateRegion(rec!), animated: true);
            
            if let steps = myRoute?.steps as [MKRoute.Step]? {
                for step in steps {
                    showRoute = showRoute + step.instructions + "\n";
                }
                self.myRouteText.text = showRoute;
            }
        });
    
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue;
        renderer.lineWidth = 2.0;
        
        return renderer
    }
    
    @IBAction func findNearby(_ sender: Any) {
        // initialize the search request
        let searchReq = MKLocalSearch.Request();
        
        // Set my parameters for where to serach
        searchReq.naturalLanguageQuery = self.nearbyField.text!;
        searchReq.region = self.myMapView.region;
        
        // Search using those settings using MKLocalSearch
        let ls = MKLocalSearch(request: searchReq);
        ls.start(completionHandler: {
            searchResponse, searchErr in
            
            if searchErr != nil{
                print("error searching")
                return;
            }
            
            let mapItems = searchResponse!.mapItems as [MKMapItem];
            var annotations: [MKAnnotation] = [];
            if !mapItems.isEmpty{
                for item in mapItems {
                    let anno = MKPointAnnotation();
                    anno.coordinate = (item.placemark.location?.coordinate)!;
                    anno.title = item.name
                    annotations.append(anno);
                }
            }
            
            self.myMapView.showAnnotations(annotations, animated: true);
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.myMapView = mapView;
        self.myRouteText = routeText;
        myLocMgr.delegate = self;
        myLocMgr.requestWhenInUseAuthorization();
        myMapView.delegate = self;
        myMapView.showsUserLocation = true;
        
        let annotation = MKPointAnnotation();
        let location = CLLocation(latitude: self.lat, longitude: self.lon)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            let placemark = placemarks![0];
            
            self.placemarker = placemark;
            
            annotation.title = placemark.name;
            annotation.coordinate = placemark.location!.coordinate;
            self.myMapView.addAnnotation(annotation);
            self.myMapView.showAnnotations([annotation], animated: true)
            self.renderRoute();
        });
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
