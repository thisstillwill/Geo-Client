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
    @State var showAddPointView = false
    @State var updatingPoints: Task<Void, Never>?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                
                // Main map screen
                Map(
                    coordinateRegion: $locationManager.region,
                    interactionModes: .all,
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
                        guard let oldCenter = locationManager.currentLocation else { return }
                        if (oldCenter != newRegion.center) {
                            locationManager.followingUser = false
                        }
                    }
                }
                .onAppear {
                    locationManager.startUpdatingLocation()
                    updatingPoints = locationManager.startUpdatingAnnotations()
                    
                    //                // DEBUGGING
                    //                Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                    //                    print("Following user: \(locationManager.followingUser)")
                    //                })
                }
                .onDisappear {
                    locationManager.stopUpdatingLocation()
                    updatingPoints?.cancel()
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
                        updatingPoints?.cancel()
                        updatingPoints = locationManager.startUpdatingAnnotations()
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
                        if locationManager.canAddPoint() {
                            updatingPoints?.cancel()
                            locationManager.stopUpdatingLocation()
                            showAddPointView.toggle()
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
                        )).fullScreenCover(isPresented: $showAddPointView, onDismiss: {
                            locationManager.startUpdatingLocation()
                            updatingPoints = locationManager.startUpdatingAnnotations()
                        }) {
                            if let location = locationManager.currentLocation {
                                AddPointView(isPresented: $showAddPointView, location: location, settingsManager: settingsManager)
                            }
                        }
                }.offset(
                    x: -(UIScreen.main.bounds.width / 16),
                    y: -(UIScreen.main.bounds.width / 8)
                )
            }.alert(isPresented: $locationManager.showAlert) {
                Alert(
                    title: Text(locationManager.alertTitle),
                    message: Text(locationManager.alertMessage)
                )
            }
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
