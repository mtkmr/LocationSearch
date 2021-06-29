//
//  LocationManager.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/06/29.
//

import Foundation
import CoreLocation

struct Location {
    let title: String
    let coodinate: CLLocationCoordinate2D?
}

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    
    var completion: ((CLLocation) -> Void)?
    
    func getUserLocation(completion: ((CLLocation) -> Void)?) {
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    ///クエリからジオコーディングしてクロージャ([Location]) -> Voidを返す
    func findLocation(with query: String, completion: (([Location]) -> Void)?) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { (places, error) in
            guard let places = places, error == nil else {
                completion?([])
                return
            }
            
            let locations: [Location] = places.compactMap({ place in
                var name = ""
                //国
                if let country = place.country {
                    name += "\(country)"
                }
                //県
                if let adminArea = place.administrativeArea {
                    name += " \(adminArea)"
                }
                //市区町村
                if let locality = place.locality {
                    name += " \(locality)"
                }
                //地名
                if let locationName = place.thoroughfare {
                    name += " \(locationName)"
                 }
                
                let results = Location(
                    title: name,
                    coodinate: place.location?.coordinate
                )
                return results
            })
            completion?(locations)
        }
    }
    
    //locationから逆ジオコーディングしてクロージャ(placeName) -> Voidを返す
    func resolveLocationName(with location: CLLocation,
                             completion: ((String?) -> Void)?) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (places, error) in
            guard let place = places?.first, error == nil else {
                completion?(nil)
                return
            }
            
            var name = ""
            if let adminArea = place.administrativeArea {
                name += adminArea
            }
            if let locality = place.locality {
                name += " \(locality)"
            }
            if let locationName = place.thoroughfare {
                name += " \(locationName)"
             }
            
            completion?(name)
            
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completion?(location)
        manager.stopUpdatingLocation()
    }
}
