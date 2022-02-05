//
//  MapViewModel.swift
//  Geo
//
//  Created by William Svoboda on 11/11/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI
import MapKit

// By default map is centered roughly on West Point, New York
enum MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 41.23, longitude: -73.58)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /* TODO:
     By using MapUserTrackingMode, the zoom level will be auto-adjusted.
     If I want to keep a closer zoom by default, I will need to handle user tracking myself
     based on location changes.
     */
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultLocation,
        span: MapDetails.defaultSpan
    )
    @Published var trackingMode: MapUserTrackingMode = .none
    @Published var annotations: [Point] = []
    
    var locationManager: CLLocationManager?
    
    func checkLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.activityType = CLActivityType.other
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            //annotations = getAnnotations()
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
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? MapDetails.defaultLocation, span: MapDetails.defaultSpan)
            trackingMode = .follow
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorized()
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        return locationManager!.location!.coordinate
    }
    
    /* TODO:
     Replace function with actual network call
     */
    func getMapAnnotations() {
        // Configure data request
        let currentLocation = getCurrentLocation()
        let url = URL(string: "http://localhost:6379/points?latitude=\(currentLocation.latitude)&longitude=\(currentLocation.longitude)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Create and start data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                      print ("server error")
                      return
                  }
            guard let data = data else {
                print("error: did not receive data")
                return
            }
            do {
                let points = try JSONDecoder().decode([Point].self, from: data)
                print(points)
                self.annotations = points
            } catch {
                print("error: could not deserialize JSON")
                return
            }
        }
        task.resume()
        
//        annotations.append(contentsOf: TestPoints.points)
//        annotations.append(TestPoints.lot19)
//        annotations.append(TestPoints.nowhere)
//        print(annotations)
    }
}
