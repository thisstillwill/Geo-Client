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
    
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
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
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
