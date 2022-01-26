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
    var showAlert = false
}

final class AddPointViewModel: ObservableObject {
    
    @Published var state: AddPointState
    
    init() {
        self.state = AddPointState()
    }
    
    func isValid() -> Bool {
        return !state.title.isEmpty
    }
    
    func submitForm() {
        if isValid() {
            // Submit to point to server
            state.showAlert = false
            print(state)
        }
        else {
            state.showAlert = true
        }
    }
}
