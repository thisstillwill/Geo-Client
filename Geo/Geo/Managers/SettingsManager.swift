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

final class SettingsManager: ObservableObject {
    @Published var scheme: String = "http"
    @Published var host: String = "localhost"
    @Published var port: Int = 6379
    @Published var mapRefreshDelay: UInt64 = 5_000_000_000
    @Published var searchRadiusMeters: CLLocationDistance = 1600
    @Published var interactRadiusMeters: CLLocationDistance = 200
    @Published var adjacentPointRestriction: CLLocationDistance = 15
    @Published var inRangeColor: Color = .red
    @Published var notInRangeColor: Color = .gray
    @Published var maxTitleLength: Int = 60
    @Published var maxDescriptionLength: Int = 280
}
