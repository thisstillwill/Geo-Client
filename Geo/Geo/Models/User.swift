//
//  User.swift
//  Geo
//
//  Created by William Svoboda on 3/29/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation

// A User represents a single, unique user and their information
struct User: Identifiable, Codable {
    let id: String
    let email: String
    let givenName: String
    let familyName: String
}
