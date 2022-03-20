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
    let locationManager: LocationManager
    
    init() {
        settingsManager = SettingsManager()
        locationManager = LocationManager(settingsManager: settingsManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
                .environmentObject(locationManager)
        }
    }
}
