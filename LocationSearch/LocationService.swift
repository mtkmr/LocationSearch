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

final class LocationService: NSObject {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    
    private var completion: ((CLLocation) -> Void)?
    
    func startUpdateLocation() {
        manager.startUpdatingLocation()
    }
    
    func getUserLocation(completion: ((CLLocation) -> Void)?) {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.completion = completion
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

//MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard
            CLLocationManager.locationServicesEnabled()
        else {
            print("「設定」→「プライバシー」→「位置情報サービス」より位置情報の取得を許可してください")
            return
        }
        
        switch manager.authorizationStatus {
        case .denied:
            print("「設定」アプリから位置情報の取得を許可してください")
        case .restricted:
            print("何らかの制限がかかっています")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        @unknown default:
            fatalError("予期せぬ位置情報認証エラーが発生しました")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
