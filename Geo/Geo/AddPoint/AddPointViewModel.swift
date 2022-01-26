//
//  AddPointViewModel.swift
//  Geo
//
//  Created by William Svoboda on 1/25/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import Foundation

struct AddPointState: Equatable {
    var title: String = ""
    var showAlert = false
}

final class AddPointViewModel: ObservableObject {
    
    @Published var state: AddPointState
    
    init() {
        self.state = AddPointState()
    }
    
    func updateTitle(_ title: String) {
        state.title = title
    }
    
    func isValid() -> Bool {
        return !state.title.isEmpty
    }
    
    func submitForm() {
        if isValid() {
            // Submit to point to server
            print(state)
        }
        else {
            state.showAlert = true
        }
    }
}
