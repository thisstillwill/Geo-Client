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
        return !state.title.isEmpty
    }
    
    func submitForm() async throws {
//        if isValid() {
//            // Create a new point matching current location
//            state.showAlert = false
//            let newPoint = Point(id: "", title: state.title, location: state.location!)
//            let encodedPoint = try JSONEncoder().encode(newPoint)
//
//            // Configure upload request
//            let url = URL(string: "http://localhost:6379/points")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            // Create and start upload task
//            let task = URLSession.shared.uploadTask(with: request, from: encodedPoint) { data, response, error in
//                if let error = error {
//                    print ("error: \(error)")
//                    return
//                }
//                guard let response = response as? HTTPURLResponse,
//                      (200...299).contains(response.statusCode) else {
//                          print ("server error")
//                          return
//                      }
//                if let mimeType = response.mimeType,
//                   mimeType == "application/json",
//                   let data = data,
//                   let dataString = String(data: data, encoding: .utf8) {
//                    print ("got data: \(dataString)")
//                }
//            }
//            task.resume()
//            print("Submitted: \(state.hasSubmitted)")
//        }
//        else {
//            state.showAlert = true
//        }
        guard isValid() else {
            state.showAlert = true
            return
        }
        
        state.showAlert = false
        let newPoint = Point(id: "", title: state.title, location: state.location!)
        let encodedPoint = try JSONEncoder().encode(newPoint)
        
        let url = URL(string: "http://localhost:6379/points")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: encodedPoint)

        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else { throw NSError() }
    }
}
