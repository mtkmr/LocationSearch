//
//  ViewController.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/06/29.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation

final class MainViewController: UIViewController {
    
    private lazy var mapView: MKMapView = {
       let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()
    
    private let panelController = FloatingPanelController()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.addSubview(mapView)
        
        let searchVC = SearchViewController()
        searchVC.delegate = self
        
        panelController.set(contentViewController: searchVC)
        panelController.addPanel(toParent: self)
        
        LocationManager.shared.getUserLocation { [weak self] (location) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                strongSelf.addMapPin(with: location)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    private func addMapPin(with location: CLLocation) {
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPointAnnotation()
        mapView.setRegion(MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(
                                latitudeDelta: 0.7,
                                longitudeDelta: 0.7
                            )
        ),
                          animated: true)
        pin.coordinate = location.coordinate
        mapView.addAnnotation(pin)
        
        LocationManager.shared.resolveLocationName(with: location) { [weak self] (locationName) in
            self?.title = locationName
        }
    }
    
}

extension MainViewController: SearchViewControllerDelegate {
    
    func searchViewController(_ vc: SearchViewController, didSelectLocationWith coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        //floatingPanelを最小にする
        panelController.move(to: .tip, animated: true)
        
        addMapPin(with: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        
        LocationManager.shared.resolveLocationName(with: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] (locationName) in
            self?.title = locationName
        }
        
        mapView.setRegion(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.7,
                longitudeDelta: 0.7
            )
        ),
        animated: true)
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil {
            //create the View
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        annotationView?.image = UIImage(named: "human")

        return annotationView
    }
}
