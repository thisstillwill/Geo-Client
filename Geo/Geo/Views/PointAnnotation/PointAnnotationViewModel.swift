//
//  PointAnnotationViewModel.swift
//  Geo
//
//  Created by William Svoboda on 4/6/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

final class PointAnnotationViewModel: ObservableObject {
    // Injected dependencies
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var locationManager: LocationManager
    
    @Published var inRangeColor: Color
    @Published var notInRangeColor: Color
    @Published var showPointDetailsView = false
    
    init(settingsManager: SettingsManager, locationManager: LocationManager) {
        self.settingsManager = settingsManager
        self.locationManager = locationManager
        self.inRangeColor = settingsManager.inRangeColor
        self.notInRangeColor = settingsManager.notInRangeColor
    }
    
    func canInteract(otherLocation: CLLocationCoordinate2D) -> Bool {
        do {
            let currentLocation = try locationManager.getCurrentLocation()
            return currentLocation.distance(from: otherLocation) <= settingsManager.interactRadiusMeters
        } catch {
            return false
        }
    }
}
