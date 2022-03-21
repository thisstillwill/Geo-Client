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

struct AddPointState {
    var showAlert = false
    var alertTitle: String = "Error!"
    var alertMessage: String = "An error has occurred."
    var hasSubmitted = false
}

final class AddPointViewModel: ObservableObject {
    
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var locationManager: LocationManager
    @Published var state: AddPointState
    @Published var title: String = "" {
        didSet {
            if title.contains("\n") {
                title = title.replacingOccurrences(of: "\n", with: "")
            }
            if title.count > settingsManager.maxTitleLength {
                title = String(title.prefix(settingsManager.maxTitleLength))
                state.showAlert = true
                state.alertTitle = "Character limit reached!"
                state.alertMessage = "Titles can be a maximum of \(settingsManager.maxTitleLength) characters. Descriptions can be a maximum of \(settingsManager.maxDescriptionLength) characters."
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
                state.showAlert = true
                state.alertTitle = "Character limit reached!"
                state.alertMessage = "Titles can be a maximum of \(settingsManager.maxTitleLength) characters. Descriptions can be a maximum of \(settingsManager.maxDescriptionLength) characters."
            }
        }
    }
    
    init(settingsManager: SettingsManager, locationManager: LocationManager) {
        self.settingsManager = settingsManager
        self.locationManager = locationManager
        self.state = AddPointState()
    }
    
    func isValid() -> Bool {
        return !title.isEmpty && !description.isEmpty
    }
    
    func submitForm() async throws {
        guard isValid() else {
            state.showAlert = true
            state.alertTitle = "Submission error!"
            state.alertMessage = "One or more form values are missing."
            return
        }
        
        guard let location = locationManager.currentLocation else {
            state.showAlert = true
            state.alertTitle = "Location error!"
            state.alertMessage = "There was a problem getting your current location."
            return
        }
        
        let newPoint = Point(id: "", title: title, body: description, location: location)
        let encodedPoint = try JSONEncoder().encode(newPoint)
        
        var components = URLComponents()
        components.scheme = settingsManager.scheme
        components.host = settingsManager.host
        components.port = settingsManager.port
        components.path = "/points"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: encodedPoint)

        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else { throw NSError() }
        
        DispatchQueue.main.async {
            self.state.showAlert = false
            self.state.hasSubmitted = true
        }
    }
}
