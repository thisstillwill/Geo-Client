//
//  LoginViewModel.swift
//  Geo
//
//  Created by William Svoboda on 4/4/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftUI

final class LoginViewModel: ObservableObject {
    @ObservedObject var authenticationManager: AuthenticationManager
    @Published var checkingSession = true
    
    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }
    
    // Check if a user already has a previous sign-in user
    func checkSession() async {
        do {
            print("checking session")
            try await authenticationManager.signIn()
        } catch {
            // Automatic sign-in failed, reverting to manual authentication
            print("Failed to automatically sign in!")
            print(error)
            checkingSession = false
        }
    }
    
    // Make the appropriate authentication request from the given credential
    public func handleCredential(appleIDCredential: ASAuthorizationAppleIDCredential) {
        // New user
        if let _ = appleIDCredential.email, let _ = appleIDCredential.fullName {
            Task {
                do {
                    try await authenticationManager.signUp(appleIDCredential: appleIDCredential, restoringUser: false)
                } catch {
                    print(error)
                }
            }
        } else {
            // Returning user
            Task {
                do {
                    try await authenticationManager.signIn(appleIDCredential: appleIDCredential)
                } catch {
                    print(error)
                }
            }
        }
    }
}
