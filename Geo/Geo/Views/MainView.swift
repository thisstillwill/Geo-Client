//
//  MainView.swift
//  Geo
//
//  Created by William Svoboda on 4/7/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView {
            MapView(viewModel: MapViewModel(settingsManager: settingsManager, locationManager: locationManager, authenticationManager: authenticationManager))
                .tabItem {
                    Label("Map", systemImage: "mappin.and.ellipse")
                }
            SettingsView(viewModel: SettingsViewModel(authenticationManager: authenticationManager))
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SettingsManager())
            .environmentObject(AuthenticationManager(settingsManager: SettingsManager()))
            .environmentObject(LocationManager(settingsManager: SettingsManager()))
    }
}
