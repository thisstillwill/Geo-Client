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
    
    @StateObject var locationManager = MapViewModel()
    
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
                    NavigationLink {
                        PointAnnotationDetailsView(point: point)
                    } label: {
                        PointAnnotationView()
                    }
                }
            }
            .ignoresSafeArea()
            .task {
                do {
                    try await locationManager.getMapAnnotations()
                    while true {
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        try await locationManager.getMapAnnotations()
                    }
                } catch {
                    print("Could not connect to server!")
                    return
                }
            }
            
            // Add point button
            NavigationLink(destination: AddPointView().environmentObject(locationManager), label: {
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
    }
}
