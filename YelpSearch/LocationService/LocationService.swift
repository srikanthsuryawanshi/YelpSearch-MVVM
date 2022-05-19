//
//  LocationService.swift
//  YelpSearch
//
//  Created by Srikanth SP on 28/03/22.
//

import Foundation
import CoreLocation



struct YelpLocation {
    let latitude: Double
    let longitude: Double
    var name: String?
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}


protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(location: YelpLocation)
}

protocol LocationServiceProtocol {
    func fetchCurrentLocation()
    var delegate: LocationServiceDelegate? { get set }
}

class LocationService: NSObject {
    
    weak var delegate: LocationServiceDelegate?
    
    private var currentLocation: CLLocation?
    
    lazy var locationManager: CLLocationManager = {
       
        var manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()    
}

extension LocationService: LocationServiceProtocol {
    func fetchCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //handle authorization
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:  locationManager.requestLocation()
        case .authorizedAlways:     locationManager.requestLocation()
        case .denied:
            print("ERROR -  Authorisation denied.")
        
        case .notDetermined:
            print("ERROR -  Authorisation notDetermined.")
        case .restricted: print("ERROR -  Authorisation restricted.")
        @unknown default:
            print("ERROR -  Authorisation UNKNOWN.")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error- \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //
        if !locations.isEmpty, let locn = locations.last {
             currentLocation = locn
            delegate?.didUpdateLocation(location: YelpLocation(location: locn))
        }
    }
}
