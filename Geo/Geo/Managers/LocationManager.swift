//
//  MapViewModel.swift
//  Geo
//
//  Created by William Svoboda on 11/11/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI
import MapKit

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
    @Published var trackingMode: MapUserTrackingMode = .none
    @Published var annotations: [Point] = []
    
    private let locationManager = CLLocationManager()
    
    init(settingsManager: SettingsManager) {
        
        self.settingsManager = settingsManager
        
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.activityType = CLActivityType.other
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location services is required to use this app.")
        }
    }
    
    func checkLocationAuthorized() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted (likely due to parental controls).")
        case .denied:
            print("You have denied this app location permission.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? MapDetails.defaultLocation, span: MapDetails.defaultSpan)
            trackingMode = .none
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
    func resetRegion() {
        guard let currentLocation = self.currentLocation else {
            return
        }
        self.region = MKCoordinateRegion(center: currentLocation, span: MapDetails.defaultSpan)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            self.region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
        }
    }
    
    func getMapAnnotations() async throws {
        
        guard let currentLocation = currentLocation else { return }
        
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/points"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(currentLocation.latitude)),
            URLQueryItem(name: "longitude", value: String(currentLocation.longitude)),
            URLQueryItem(name: "radius", value: String(settingsManager.searchRadiusMeters))
        ]
        
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        let points = try JSONDecoder().decode([Point].self, from: data)
        
        DispatchQueue.main.async {
            self.annotations = points
        }
        
//        annotations.append(contentsOf: TestPoints.points)
//        annotations.append(TestPoints.lot19)
//        annotations.append(TestPoints.nowhere)
//        print(annotations)
    }
    
    func inRange(otherLocation: CLLocationCoordinate2D) -> Bool {
        return (currentLocation?.distance(from: otherLocation) ?? Double.infinity) < settingsManager.interactRadiusMeters
    }
}

// TODO: Determine if I actually need these
extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }
}
