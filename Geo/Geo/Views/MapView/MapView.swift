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
    
    @StateObject var viewModel = MapViewModel()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // Main map screen
            Map(
                coordinateRegion: $viewModel.region,
                interactionModes: MapInteractionModes.all,
                showsUserLocation: true,
                userTrackingMode: $viewModel.trackingMode,
                annotationItems: viewModel.annotations
            ) {
                point in MapAnnotation(coordinate: point.location) {
                    PointAnnotationView(title: point.title)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.checkLocationServicesEnabled()
                viewModel.getMapAnnotations()
            }
            
            // Add point button
            NavigationLink(destination: AddPointView().environmentObject(viewModel), label: {
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
