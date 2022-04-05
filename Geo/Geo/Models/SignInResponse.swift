//
//  SignInResponse.swift
//  Geo
//
//  Created by William Svoboda on 4/4/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation

// A SignInResponse represents a user and refresh token obtained from the server
struct SignInResponse: Codable {
    let user: User
    let token: TokenResponse
}
