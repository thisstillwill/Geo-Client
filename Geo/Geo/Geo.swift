//
//  Geo.swift
//  Geo
//
//  Created by William Svoboda on 11/15/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI

@main
struct Geo: App {
    
    let settingsManager: SettingsManager
    let authenticationManager: AuthenticationManager
    let locationManager: LocationManager
    
    init() {
        self.settingsManager = SettingsManager()
        self.authenticationManager = AuthenticationManager(settingsManager: settingsManager)
        self.locationManager = LocationManager(settingsManager: settingsManager)
    }
    
    // Inject required services after initializing the app
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
                .environmentObject(authenticationManager)
                .environmentObject(locationManager)
        }
    }
}
