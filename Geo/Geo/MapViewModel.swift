//
//  MapViewModel.swift
//  Geo
//
//  Created by William Svoboda on 11/11/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import MapKit

// By default map is centered roughly on Princeton, New Jersey
enum MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 40.35, longitude: -74.66)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultLocation,
        span: MapDetails.defaultSpan
    )
    
    var locationManager: CLLocationManager?
    
    func checkLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.activityType = CLActivityType.other
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Location services is required to use this app.")
        }
    }
    
    func checkLocationAuthorized() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted (likely due to parental controls).")
        case .denied:
            print("You have denied this app location permission.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
}
