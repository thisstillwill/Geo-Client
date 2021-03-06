//
//  SettingsManager.swift
//  Geo
//
//  Created by William Svoboda on 3/20/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit

// Manage global settings and other important default values
final class SettingsManager: ObservableObject {
//    @Published var scheme: String = "http"
//    @Published var host: String = "Williams-MacBook-Pro.local"
//    @Published var port: Int = 6379
    @Published var scheme: String = "http"
    @Published var host: String = "167.172.134.3"
    @Published var port: Int = 6379
    @Published var mapRefreshDelay: UInt64 = 5_000_000_000
    @Published var searchRadiusMeters: CLLocationDistance = 1600
    @Published var interactRadiusMeters: CLLocationDistance = 200
    @Published var adjacentPointRestriction: CLLocationDistance = 20
    @Published var inRangeColor: Color = .red
    @Published var notInRangeColor: Color = .gray
    @Published var maxTitleLength: Int = 60
    @Published var maxDescriptionLength: Int = 280
}
