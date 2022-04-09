//
//  SettingsViewModel.swift
//  Geo
//
//  Created by William Svoboda on 4/7/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    // Injected dependencies
    @ObservedObject var authenticationManager: AuthenticationManager
    
    // Published properties
    @Published var user: User?
    
    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
        self.user = authenticationManager.currentUser
    }
    
    func logout() {
        authenticationManager.logout()
    }
}
