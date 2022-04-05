//
//  MapViewModel.swift
//  Geo
//
//  Created by William Svoboda on 11/11/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI
import MapKit

enum LocationError: Error {
    case locationMissing
}

// By default map is centered on "Null Island"
enum MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @ObservedObject var settingsManager: SettingsManager
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultLocation,
        span: MapDetails.defaultSpan
    )
    @Published var annotations: [Point] = []
    @Published var showAlert = false
    @Published var alertTitle: String = "Error!"
    @Published var alertMessage: String = "An error has occurred."
    
    private let locationManager = CLLocationManager()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.activityType = CLActivityType.other
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorized() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted (likely due to parental controls).")
        case .denied:
            print("You have denied this app location permission.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? MapDetails.defaultLocation, span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
    func canInteract(otherLocation: CLLocationCoordinate2D) -> Bool {
        return (currentLocation?.distance(from: otherLocation) ?? Double.infinity) < settingsManager.interactRadiusMeters
    }
    
    func getCurrentLocation() throws -> CLLocationCoordinate2D {
        guard let currentLocation = currentLocation else { throw LocationError.locationMissing }
        return currentLocation
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            print("Started updating location!")
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location services is required to use this app.")
        }
    }
    
    func stopUpdatingLocation() {
        print("Stopped updating location!")
        self.locationManager.stopUpdatingLocation()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            self.region = MKCoordinateRegion(center: location.coordinate, span: self.region.span)
        }
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}
