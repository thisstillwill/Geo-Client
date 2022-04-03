//
//  TokenResponse.swift
//  Geo
//
//  Created by William Svoboda on 4/3/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation

// A TokenResponse represents a refresh token obtained from the server
struct TokenResponse: Codable {
    let token: String
}
