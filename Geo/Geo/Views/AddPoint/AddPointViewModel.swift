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
    var title: String = ""
    var body: String = ""
    var location: CLLocationCoordinate2D?
    var showAlert = false
    var hasSubmitted = false
}

final class AddPointViewModel: ObservableObject {
    
    @ObservedObject var settingsManager: SettingsManager
    @Published var state: AddPointState
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        self.state = AddPointState()
    }
    
    func isValid() -> Bool {
        return !state.title.isEmpty && !state.body.isEmpty
    }
    
    func submitForm() async throws {
        guard isValid() else {
            state.showAlert = true
            return
        }
        
        let newPoint = Point(id: "", title: state.title, body: state.body, location: state.location!)
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
