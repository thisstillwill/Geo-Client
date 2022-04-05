//
//  DependencyManager.swift
//  Geo
//
//  Created by William Svoboda on 4/4/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import SwiftUI

final class DependencyManager: ObservableObject {
    let settingsManager: SettingsManager
    let authenticationManager: AuthenticationManager
    let locationManager: LocationManager
    
    init(settingsManager: SettingsManager, authenticationManager: AuthenticationManager, locationManager: LocationManager) {
        self.settingsManager = settingsManager
        self.authenticationManager = authenticationManager
        self.locationManager = locationManager
    }
}
