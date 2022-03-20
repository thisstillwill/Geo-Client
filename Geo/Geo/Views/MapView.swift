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
            
            // Add point button
            NavigationLink(destination: AddPointView(settingsManager: settingsManager), label: {
                Image(systemName: "plus")
            })
                .buttonStyle(CircleButton(color: .red, radius: 100))
                .offset(x: -50, y: -100)
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
