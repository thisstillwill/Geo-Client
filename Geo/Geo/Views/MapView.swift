//
//  MapView.swift
//  Geo
//
//  Created by William Svoboda on 11/1/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // Main map screen
            Map(
                coordinateRegion: $locationManager.region,
                interactionModes: MapInteractionModes.all,
                showsUserLocation: true,
                userTrackingMode: $locationManager.trackingMode,
                annotationItems: locationManager.annotations
            ) {
                point in MapAnnotation(coordinate: point.location) {
                    PointAnnotationView(point: point)
                        .environmentObject(settingsManager)
                        .environmentObject(locationManager)
                }
            }
            .ignoresSafeArea()
            .onChange(of: locationManager.region) { newRegion in
                if (locationManager.followingUser) {
                    guard let oldCenter = locationManager.currentLocation else {
                        return
                    }
                    if (oldCenter != newRegion.center) {
                        locationManager.followingUser = false
                    }
                }
            }
            .task {
                do {
                    while true {
                        try await locationManager.getMapAnnotations()
                        try await Task.sleep(nanoseconds: settingsManager.mapRefreshDelay)
                    }
                } catch {
                    print("Could not connect to server!")
                    return
                }
            }
            
            // Button stack
            VStack(spacing: 10) {
                
                // Reset view button
                Button(action: {
                    // TODO: Figure out using withAnimation?
                    locationManager.resetRegion()
                }) {
                    Image(systemName: "location.fill")
                }.buttonStyle(
                    CircleButton(
                        foregroundColor: .blue,
                        backgroundColor: .white,
                        radius: 65,
                        fontSize: 30,
                        fontWeight: .regular
                    ))
                
                // Refresh map button
                Button(action: {
                    Task {
                        do {
                            try await locationManager.getMapAnnotations()
                        } catch {
                            print("Could not connect to server!")
                            return
                        }
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                }.buttonStyle(
                    CircleButton(
                        foregroundColor: .white,
                        backgroundColor: .gray,
                        radius: 65,
                        fontSize: 30,
                        fontWeight: .regular
                    ))
                
                // Add point button
                NavigationLink(destination: AddPointView(settingsManager: settingsManager, locationManager: locationManager), label: {
                    Image(systemName: "plus")
                })
                    .buttonStyle(
                        CircleButton(
                            foregroundColor: .white,
                            backgroundColor: .red,
                            radius: 120,
                            fontSize: 72,
                            fontWeight: .regular
                        ))
            }.offset(
                x: -(UIScreen.main.bounds.width / 16),
                y: -(UIScreen.main.bounds.width / 8)
            )
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(SettingsManager())
            .environmentObject(LocationManager(settingsManager: SettingsManager()))
    }
}
