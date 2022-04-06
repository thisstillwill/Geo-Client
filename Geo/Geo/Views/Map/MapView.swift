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
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @StateObject var viewModel: MapViewModel
    
    // View state
    @State var showAddPointView = false
    @State var updatingPoints: Task<Void, Never>?
    
    var body: some View {
        
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                
                // Main map screen
                Map(
                    coordinateRegion: $viewModel.coordinateRegion,
                    interactionModes: viewModel.interactionModes,
                    showsUserLocation: true,
                    userTrackingMode: $viewModel.trackingMode,
                    annotationItems: viewModel.pointAnnotations
                ) {
                    point in MapAnnotation(coordinate: point.location) {
                        PointAnnotationView(viewModel: PointAnnotationViewModel(settingsManager: settingsManager, locationManager: locationManager), point: point)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    viewModel.startUpdatingLocation()
                    updatingPoints = viewModel.startUpdatingAnnotations()
                }
                .onDisappear {
                    viewModel.stopUpdatingLocation()
                    updatingPoints?.cancel()
                }
                
                // Button stack
                VStack(spacing: 10) {
                    
                    // Refresh map button
                    Button(action: {
                        updatingPoints?.cancel()
                        updatingPoints = viewModel.startUpdatingAnnotations()
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
                    Button(action: {
                        if viewModel.canAddPoint() {
                            viewModel.stopUpdatingLocation()
                            updatingPoints?.cancel()
                            showAddPointView = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }.buttonStyle(
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
            }.alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
                )
            }.fullScreenCover(isPresented: $showAddPointView, onDismiss: {
                viewModel.startUpdatingLocation()
                updatingPoints = viewModel.startUpdatingAnnotations()
            }) {
                if let location = viewModel.getCurrentLocation(), let user = viewModel.getCurrentUser() {
                    AddPointView(viewModel: AddPointViewModel(isPresented: $showAddPointView, user: user, location: location, settingsManager: settingsManager, authenticationManager: authenticationManager))
                }
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(viewModel: MapViewModel(settingsManager: SettingsManager(), locationManager: LocationManager(settingsManager: SettingsManager()), authenticationManager: AuthenticationManager(settingsManager: SettingsManager())))
    }
}
