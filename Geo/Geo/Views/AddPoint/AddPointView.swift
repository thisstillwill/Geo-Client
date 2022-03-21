//
//  AddPointView.swift
//  Geo
//
//  Created by William Svoboda on 1/25/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI
import CoreLocation

struct AddPointView: View {
    
    @ObservedObject var viewModel: AddPointViewModel
    @State var returnToMap = false
    
    init (settingsManager: SettingsManager, locationManager: LocationManager) {
        self.viewModel = AddPointViewModel(settingsManager: settingsManager, locationManager: locationManager)
    }
    
    var body: some View {
        if (!returnToMap) {
            Form(content: {
                
                // Point information fields
                Section(header: Text("Title and Description")) {
                    TextEditor(text: $viewModel.title)
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 200, maxHeight: 200)
                }
                
                // Submit button
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.submitForm()
                                if (viewModel.state.hasSubmitted) {
                                    self.returnToMap = true
                                }
                            } catch {
                                print("Could not submit point to server!")
                                return
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Submit")
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .listRowBackground(Color.blue)
                }
            })
                .navigationTitle("Add Point")
                .alert(isPresented: $viewModel.state.showAlert) {
                    Alert(
                        title: Text(viewModel.state.alertTitle),
                        message: Text(viewModel.state.alertMessage)
                    )
                }
        } else {
            MapView()
        }
    }
}

struct AddPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointView(settingsManager: SettingsManager(), locationManager: LocationManager(settingsManager: SettingsManager()))
    }
}
