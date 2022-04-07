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
    let poster: String
    let posted: Date
    let title: String
    let body: String
    let location: CLLocationCoordinate2D
    
    // Overloaded init for testing and server upload
    init(id: String, poster: String, posted: Date, title: String, body: String, location: CLLocationCoordinate2D) {
        self.id = id
        self.poster = poster
        self.posted = posted
        self.title = title
        self.body = body
        self.location = location
    }
    
    // Facilitate serialization
    // Adapted from https://medium.com/@nictheawesome/using-codable-with-nested-json-is-both-easy-and-fun-19375246c9ff
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case poster = "poster"
        case posted = "posted"
        case title = "title"
        case body = "body"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        id = try response.decode(String.self, forKey: .id)
        poster = try response.decode(String.self, forKey: .poster)
        posted = try response.decode(Date.self, forKey: .posted)
        title = try response.decode(String.self, forKey: .title)
        body = try response.decode(String.self, forKey: .body)
        let latitude = try response.decode(Double.self, forKey: .latitude)
        let longitude = try response.decode(Double.self, forKey: .longitude)
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    func encode(to encoder: Encoder) throws {
        var response = encoder.container(keyedBy: CodingKeys.self)
        try response.encode(id, forKey: .id)
        try response.encode(poster, forKey: .poster)
        try response.encode(posted, forKey: .posted)
        try response.encode(title, forKey: .title)
        try response.encode(body, forKey: .body)
        try response.encode(location.latitude, forKey: .latitude)
        try response.encode(location.longitude, forKey: .longitude)
    }
}

//
// TESTING ONLY
//
struct TestPoints {
    static let points: [Point] = [firestone, dod]
    static let firestone = Point(id: UUID().uuidString, poster: "John Doe", posted: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, title: "Firestone Library", body: "This is Firestone Library. I have spent many moons here.", location: CLLocationCoordinate2D(latitude: 40.34961421019707, longitude: -74.65748434583759))
    static let dod = Point(id: UUID().uuidString, poster: "Brian Kernighan", posted: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, title: "Dod Hall", body: "Dod Hall, home. At least it was before I fucked everything up.", location: CLLocationCoordinate2D(latitude: 40.346927716711406, longitude: -74.65865037281984))
    static let lot19 = Point(id: UUID().uuidString, poster: "Jane Doe", posted: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, title: "Lot 19", body: "I used to park here since Princeton's student parking is abysmal. Then one day I was finally discovered. I now park at Wawa for $35 a week.", location: CLLocationCoordinate2D(latitude: 40.338747766989734, longitude: -74.66547887223855))
    
    // Test JSON decoding
    static let jsonString = """
    {
        "id": "12345678",
        "title": "Null Island",
        "body": "This is not a real place.",
        "latitude": 0.0,
        "longitude": 0.0,
    }
    """
    static let data = jsonString.data(using: .utf8)!
    static let nowhere = try! JSONDecoder().decode(Point.self, from: data)
}
