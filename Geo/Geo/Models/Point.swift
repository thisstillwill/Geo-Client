//
//  Point.swift
//  Geo
//
//  Created by William Svoboda on 12/23/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import Foundation
import CoreLocation

// A Point represents a single unique point of interest on the map
struct Point: Identifiable, Codable {
    let id: String? // TODO: Server generates a UUID?
    var title: String,
    location: CLLocationCoordinate2D
    
    // Overloaded init for testing and server upload
    init(id: String?, title: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.location = location
    }
    
    // Facilitate serialization
    // Adapted from https://medium.com/@nictheawesome/using-codable-with-nested-json-is-both-easy-and-fun-19375246c9ff
    enum CodingKeys: String, CodingKey {
        case point = "point"
        case id = "pk"
        case title = "title"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .point)
        id = try response.decode(String.self, forKey: .id)
        title = try response.decode(String.self, forKey: .id)
        let latitude = try response.decode(Double.self, forKey: .latitude)
        let longitude = try response.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .point)
        try response.encode(id, forKey: .id)
        try response.encode(title, forKey: .title)
        try response.encode(location.latitude, forKey: .latitude)
        try response.encode(location.longitude, forKey: .longitude)
    }
}

//
// TESTING ONLY
//
struct TestPoints {
    static let points: [Point] = [firestone, dod]
    static let firestone = Point(id: UUID().uuidString, title: "Firestone Library", location: CLLocationCoordinate2D(latitude: 40.34961421019707, longitude: -74.65748434583759))
    static let dod = Point(id: UUID().uuidString, title: "Dod Hall", location: CLLocationCoordinate2D(latitude: 40.346927716711406, longitude: -74.65865037281984))
    static let lot19 = Point(id: UUID().uuidString, title: "Lot 19", location: CLLocationCoordinate2D(latitude: 40.338747766989734, longitude: -74.66547887223855))
    
    // Test JSON decoding
    static let jsonString = """
    {"point": {
        "pk": "12345678",
        "title": "Null Island",
        "latitude": 0.0,
        "longitude": 0.0,
        }
    }
    """
    static let data = jsonString.data(using: .utf8)!
    static let nowhere = try! JSONDecoder().decode(Point.self, from: data)
}
