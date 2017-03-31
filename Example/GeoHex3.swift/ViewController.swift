//
//  ViewController.swift
//  GeoHex3.swift
//
//  Created by nekowen on 2017/03/30.
//  License: MIT License
//

import UIKit
import MapKit
import GeoHex3Swift

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    fileprivate var polygons: [MKOverlay] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawPin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func drawPin() {
        let coordinate = CLLocationCoordinate2D(latitude: 35.710063, longitude: 139.8107)
        let zone = GeoHex3.getZone(coordinate: coordinate, level: 7)
        let st = MKPointAnnotation()
        st.coordinate = zone.coordinate
        st.title = zone.code
        self.mapView.addAnnotation(st)
        self.mapView.selectAnnotation(st, animated: true)
        self.move(coordinate: zone.coordinate)
    }
    
    fileprivate func move(coordinate: CLLocationCoordinate2D) {
        var cr = mapView.region
        cr.center = coordinate
        cr.span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        self.mapView.setRegion(cr, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 1.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let nepoint = CGPoint(x: mapView.bounds.origin.x + mapView.bounds.size.width, y: mapView.bounds.origin.y)
        let swpoint = CGPoint(x: mapView.bounds.origin.x, y: mapView.bounds.origin.y + mapView.bounds.size.height)
        let ne = mapView.convert(nepoint, toCoordinateFrom: mapView)
        let sw = mapView.convert(swpoint, toCoordinateFrom: mapView)
        
        self.mapView.removeOverlays(self.polygons)
        
        let zones: [Zone] = GeoHex3.getZone(southWest: sw, northEast: ne, level: 7, buffer: false)
        self.polygons = zones.map {
            (zone) in
            let path = zone.polygon
            return MKPolygon(coordinates: path, count: path.count)
        }
        
        self.mapView.addOverlays(self.polygons)
    }
}

