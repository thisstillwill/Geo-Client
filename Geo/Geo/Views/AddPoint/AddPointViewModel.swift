//
//  AddPointViewModel.swift
//  Geo
//
//  Created by William Svoboda on 1/25/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

final class AddPointViewModel: ObservableObject {
    // Injected dependencies
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var authenticationManager: AuthenticationManager
    
    @Binding var isPresented: Bool
    @Published var maxTitleLength: Int
    @Published var maxDescriptionLength: Int
    @Published var title: String = "" {
        didSet {
            if title.contains("\n") {
                title = title.replacingOccurrences(of: "\n", with: "")
            }
            if title.count > settingsManager.maxTitleLength {
                title = String(title.prefix(settingsManager.maxTitleLength))
                showAlert = true
                alertTitle = "Character limit reached!"
                alertMessage = "Titles can be a maximum of \(settingsManager.maxTitleLength) characters. Descriptions can be a maximum of \(settingsManager.maxDescriptionLength) characters."
            }
        }
    }
    @Published var description: String = "" {
        didSet {
            if description.contains("\n") {
                description = description.replacingOccurrences(of: "\n", with: "")
            }
            if description.count > settingsManager.maxDescriptionLength {
                description = String(description.prefix(settingsManager.maxDescriptionLength))
                showAlert = true
                alertTitle = "Character limit reached!"
                alertMessage = "Titles can be a maximum of \(settingsManager.maxTitleLength) characters. Descriptions can be a maximum of \(settingsManager.maxDescriptionLength) characters."
            }
        }
    }
    @Published var submittingPoint = false
    
    // Alert info
    var showAlert = false
    var alertTitle: String = "Error!"
    var alertMessage: String = "An error has occurred."
    var hasSubmitted = false
    
    let user: User
    let location: CLLocationCoordinate2D
    
    init(isPresented: Binding<Bool>, user: User, location: CLLocationCoordinate2D, settingsManager: SettingsManager, authenticationManager: AuthenticationManager) {
        self._isPresented = isPresented
        self.user = user
        self.location = location
        self.settingsManager = settingsManager
        self.authenticationManager = authenticationManager
        self.maxTitleLength = settingsManager.maxTitleLength
        self.maxDescriptionLength = settingsManager.maxDescriptionLength
    }
    
    private func preparePosterField() -> String {
        if !user.givenName.isEmpty && !user.familyName.isEmpty {
            return String("\(user.givenName) \(user.familyName.prefix(1)).")
        } else if !user.givenName.isEmpty {
            return user.givenName
        } else if !user.familyName.isEmpty {
            return user.familyName
        } else {
            return "Anonymous"
        }
    }
    
    public func isValid() -> Bool {
        return !title.isEmpty && !description.isEmpty
    }
    
    public func submitForm() async {
        // Validate form contents and show loading spinner
        guard isValid() else {
            showAlert = true
            alertTitle = "Submission error!"
            alertMessage = "One or more form values are missing."
            return
        }
        submittingPoint = true
        
        // Prepare API request
        do {
            guard let refreshToken = authenticationManager.refreshToken else { throw AuthenticationError.missingCredentials }
            let newPoint = Point(id: "", poster: preparePosterField(), title: title, body: description, location: location)
            let encodedPoint = try JSONEncoder().encode(newPoint)
            
            var components = URLComponents()
            components.scheme = settingsManager.scheme
            components.host = settingsManager.host
            components.port = settingsManager.port
            components.path = "/points"
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.setValue(refreshToken, forHTTPHeaderField: "Authorization")
            
            let (_, response) = try await URLSession.shared.upload(for: request, from: encodedPoint)
            
            guard let response = response as? HTTPURLResponse else {
                throw AuthenticationError.badResponse
            }
            
            guard (200...299).contains(response.statusCode) else {
                if response.statusCode == 401 {
                    throw AuthenticationError.invalidCredentials
                } else {
                    throw AuthenticationError.badResponse
                }
            }
            
            DispatchQueue.main.async {
                self.isPresented = false
            }
        } catch AuthenticationError.invalidCredentials, AuthenticationError.missingCredentials {
            submittingPoint = false
            showAlert = true
            alertTitle = "Authentication error!"
            alertMessage = "Unable to verify user. Please re-open app and sign in again."
        } catch {
            submittingPoint = false
            showAlert = true
            alertTitle = "Submission error!"
            alertMessage = "Unable to connect to the server."
        }
    }
}
