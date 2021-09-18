//
//  ViewController.swift
//  LocationSearch
//
//  Created by Masato Takamura on 2021/06/29.
//

import UIKit
import MapKit
import CoreLocation


final class SearchMapViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var mapView: MKMapView = {
       let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var bossImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "boss")
        return imageView
    }()
    
    private lazy var balloon: BalloonView = {
        let balloon = BalloonView()
        balloon.backgroundColor = .clear
        return balloon
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "目的地を入力",
            attributes: [.foregroundColor: UIColor.white,
                         .font: UIFont.systemFont(ofSize: 16,
                                                  weight: .regular)]
        )
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.tintColor = .white
        textField.clearButtonMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var orderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "へ今すぐ向かってくれ"
        return label
    }()
    

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mapView)
        view.addSubview(balloon)
        view.addSubview(bossImageView)
        balloon.addSubview(textField)
        balloon.addSubview(orderLabel)
        
        createLocationButton()
        
        LocationService.shared.getUserLocation { [weak self] (location) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.updateMap(with: location)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
        bossImageView.frame = CGRect(x: 16,
                                     y: 120,
                                     width: 80,
                                     height: 80)
        balloon.frame = CGRect(x: 80,
                               y: 120,
                               width: view.frame.size.width - 100,
                               height: 80)
        textField.frame = CGRect(x: 38,
                                 y: 8,
                                 width: balloon.frame.size.width - 60,
                                 height: 30)
        orderLabel.frame = CGRect(x: 38,
                                  y: textField.frame.size.height + 16,
                                  width: balloon.frame.size.width - 60,
                                  height: 30)
        
    }
}

//MARK: - Private Extension
private extension SearchMapViewController {
    ///locationButtonをセット
    func createLocationButton() {
        let locationButton = UIButton(type: .system)
        locationButton.setTitle("お疲れ！", for: .normal)
        locationButton.setTitleColor(.systemBlue, for: .normal)
        locationButton.addTarget(self,
                                 action: #selector(didTapLocationButton(_:)),
                                 for: .touchUpInside)
        let locationBtnItem = UIBarButtonItem(customView: locationButton)
        navigationItem.setRightBarButton(locationBtnItem, animated: true)
    }
    
    ///mapのpinを更新する
    func updateMap(with location: CLLocation) {
        DispatchQueue.main.async { [weak self] in
            //pin
            self?.mapView.removeAnnotations(self!.mapView.annotations)
            let pin = MKPointAnnotation()
            self?.mapView.setRegion(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.7,longitudeDelta: 0.7)
                ),
                animated: true
            )
            pin.coordinate = location.coordinate
            self?.mapView.addAnnotation(pin)

            //title
            LocationService.shared.resolveLocationName(with: location) { (locationName) in
                self?.title = locationName
            }
        }
    }
}

//MARK: - @objc Private Extension
@objc
private extension SearchMapViewController {
    func didTapLocationButton(_ sender: UIButton) {
        LocationService.shared.startUpdateLocation()
    }
}

//MARK: - UITextFieldDelegate
extension SearchMapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            LocationService.shared.findLocation(with: text) { [weak self] (locations) in
                guard
                    let coordinate = locations.first?.coodinate
                else { return }
                self?.updateMap(with: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                LocationService.shared.resolveLocationName(with: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] (locationName) in
                    self?.title = locationName
                }
                
                self?.mapView.setRegion(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.7,
                        longitudeDelta: 0.7
                    )
                ),
                animated: true)
            }
        }
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
}

//MARK: - MKMapViewDelegate
extension SearchMapViewController: MKMapViewDelegate {
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
        annotationView?.contentMode = .scaleAspectFill

        return annotationView
    }
}
