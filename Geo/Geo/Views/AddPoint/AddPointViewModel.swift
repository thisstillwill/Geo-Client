//
//  AddPointViewModel.swift
//  Geo
//
//  Created by William Svoboda on 1/25/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation
import CoreLocation

struct AddPointState {
    var title: String = ""
    var body: String = ""
    var location: CLLocationCoordinate2D?
    var showAlert = false
    var hasSubmitted = false
}

final class AddPointViewModel: ObservableObject {
    
    @Published var state: AddPointState
    
    init() {
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
        
        let url = URL(string: "http://localhost:6379/points")!
        var request = URLRequest(url: url)
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
