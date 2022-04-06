//
//  MapViewModel.swift
//  Geo
//
//  Created by William Svoboda on 4/4/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

final class MapViewModel: ObservableObject {
    // Injected dependencies
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // Map settings
    @Published var coordinateRegion: MKCoordinateRegion
    @Published var interactionModes: MapInteractionModes = .all
    @Published var showsUserLocation = true
    @Published var trackingMode: MapUserTrackingMode = .follow
    @Published var pointAnnotations: [Point] = []
    
    // Alert info
    @Published var showAlert = false
    @Published var alertTitle: String = "Error!"
    @Published var alertMessage: String = "An error has occurred."
    
    init(settingsManager: SettingsManager, locationManager: LocationManager, authenticationManager: AuthenticationManager) {
        self.settingsManager = settingsManager
        self.locationManager = locationManager
        self.authenticationManager = authenticationManager
        self.coordinateRegion = locationManager.region
    }
    
    // Start updating location and points
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Stop updating location and points
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        do {
            return try locationManager.getCurrentLocation()
        } catch {
            showAlert = true
            alertTitle = "Application error!"
            alertMessage = "Unable to find your current location."
            return nil
        }
    }
    
    private func getMapAnnotations() async throws {
        print("Getting annotations!")
        
        let currentLocation = try locationManager.getCurrentLocation()
        guard let refreshToken = authenticationManager.refreshToken else { throw AuthenticationError.missingCredentials }
        
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
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue(refreshToken, forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw AuthenticationError.badResponse
        }
        
        guard (200...299).contains(response.statusCode) else {
            if response.statusCode == 401 {
                throw AuthenticationError.invalidCredentials
            } else {
                throw AuthenticationError.badResponse
            }
        }
        
        let points = try JSONDecoder().decode([Point].self, from: data)
        
        DispatchQueue.main.async {
            self.pointAnnotations = points
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
                    } catch AuthenticationError.invalidCredentials {
                        print("Logging out")
                        authenticationManager.logout()
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
    
    public func canAddPoint() -> Bool {
        
        do {
            let currentLocation = try locationManager.getCurrentLocation()
            if pointAnnotations.allSatisfy( { $0.location.distance(from: currentLocation) > settingsManager.adjacentPointRestriction  }) {
                return true
            } else {
                showAlert = true
                alertTitle = "Distance error!"
                alertMessage = "New points must be at least \(Int(settingsManager.adjacentPointRestriction)) meters from existing points."
                return false
            }
        } catch {
            showAlert = true
            alertTitle = "Application error!"
            alertMessage = "Unable to find your current location."
            return false
        }
    }
}
