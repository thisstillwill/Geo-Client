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
    @Published var trackingMode: MapUserTrackingMode = .follow
    @Published var annotations: [Point] = []
    @Published var followingUser = true
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
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        } else {
            print("Location services is required to use this app.")
        }
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
            trackingMode = .follow
        @unknown default:
            break
        }
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
    public func resetRegion() {
        self.followingUser = true
        guard let currentLocation = self.currentLocation else {
            return
        }
        self.region = MKCoordinateRegion(center: currentLocation, span: MapDetails.defaultSpan)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            
            if (self.followingUser) {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            }
        }
    }
    
    private func getMapAnnotations() async throws {
        print("Getting annotations!")
        
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
    }
    
    public func startUpdatingAnnotations() -> Task<Void, Never> {
        let task = Task {
            do {
                while true {
                    // Explicitly check for cancellation request
                    try Task.checkCancellation()
                    do {
                        try await getMapAnnotations()
                    } catch {
                        showAlert = true
                        alertTitle = "Server error!"
                        alertMessage = "Unable to refresh points from server."
                    }
                    try await Task.sleep(nanoseconds: settingsManager.mapRefreshDelay)
                }
            } catch {
                print("Updating annotations canceled!")
            }
        }
        return task
    }
    
    public func canInteract(otherLocation: CLLocationCoordinate2D) -> Bool {
        return (currentLocation?.distance(from: otherLocation) ?? Double.infinity) < settingsManager.interactRadiusMeters
    }
    
    public func canAddPoint() -> Bool {
        guard let location = currentLocation else {
            showAlert = true
            alertTitle = "Application error!"
            alertMessage = "Unable to find your current location."
            return false
        }
        if annotations.allSatisfy( { $0.location.distance(from: location) > settingsManager.adjacentPointRestriction  }) {
            return true
        } else {
            showAlert = true
            alertTitle = "Distance error!"
            alertMessage = "New points must be at least \(settingsManager.adjacentPointRestriction) meters from existing points."
            return false
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

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        let epsilon = 0.0001
        return abs(lhs.latitude - rhs.latitude) < epsilon && abs(lhs.longitude - rhs.longitude) < epsilon
        // lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        let epsilon = 0.0001
        return abs(lhs.latitudeDelta - rhs.latitudeDelta) < epsilon && abs(lhs.longitudeDelta - rhs.longitudeDelta) < epsilon
        // lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }
}
