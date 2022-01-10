//
//  Point.swift
//  Geo
//
//  Created by William Svoboda on 12/23/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import Foundation
import CoreLocation

// Facilitate serialization
// Adapted from https://github.com/mapbox/turf-swift/blob/1a105b11bc3acd56df71778c8769c81c033f1dcb/Sources/Turf/CoreLocation.swift#L53-L66
extension CLLocationCoordinate2D: Codable {
     public func encode(to encoder: Encoder) throws {
         var container = encoder.unkeyedContainer()
         try container.encode(latitude)
         try container.encode(longitude)
     }
      
     public init(from decoder: Decoder) throws {
         var container = try decoder.unkeyedContainer()
         let latitude = try container.decode(CLLocationDegrees.self)
         let longitude = try container.decode(CLLocationDegrees.self)
         self.init(latitude: latitude, longitude: longitude)
     }
 }

// A Point represents a single unique point of interest on the map
struct Point: Identifiable, Codable {
    let id: String? // TODO: Server generates a UUID?
    var title: String,
    location: CLLocationCoordinate2D
}

//
// TESTING ONLY
//
struct TestPoints {
    static let points: [Point] = [firestone, dod]
    static let firestone = Point(id: UUID().uuidString, title: "Firestone Library", location: CLLocationCoordinate2D(latitude: 40.34961421019707, longitude: -74.65748434583759))
    static let dod = Point(id: UUID().uuidString, title: "Dod Hall", location: CLLocationCoordinate2D(latitude: 40.346927716711406, longitude: -74.65865037281984))
}
