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

final class LocationManger: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultLocation,
        span: MapDetails.defaultSpan
    )
    @Published var trackingMode: MapUserTrackingMode = .none
    @Published var annotations: [Point] = []
    
    private var hasSetRegion = false
    private let locationManager = CLLocationManager()
    
    override init() {
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
            trackingMode = .follow
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            
            if !hasSetRegion {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
                hasSetRegion = true
            }
        }
    }
    
    func getMapAnnotations() async throws {
        
        guard let currentLocation = currentLocation else { return }
        
        let url = URL(string: "http://localhost:6379/points?latitude=\(currentLocation.latitude)&longitude=\(currentLocation.longitude)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
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
        return (currentLocation?.distance(from: otherLocation) ?? Double.infinity) < 400
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return from.distance(from: to)
    }
}
