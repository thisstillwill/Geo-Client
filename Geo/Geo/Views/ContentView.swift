//
//  ContentView.swift
//  Geo
//
//  Created by William Svoboda on 10/22/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        if (authenticationManager.isSignedIn) {
            MapView(viewModel: MapViewModel(settingsManager: settingsManager, locationManager: locationManager, authenticationManager: authenticationManager))
        } else {
            LoginView(viewModel: LoginViewModel(authenticationManager: authenticationManager))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
