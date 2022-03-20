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
    @EnvironmentObject var locationManager: LocationManager
    
    init (settingsManager: SettingsManager) {
        self.viewModel = AddPointViewModel(settingsManager: settingsManager)
    }
    
    var body: some View {
        if (!viewModel.state.hasSubmitted) {
            NavigationView {
                Form(content: {
                    
                    // Point information fields
                    Section(header: Text("Title and Description")) {
                        TextField("Title", text: $viewModel.state.title)
                        TextEditor(text: $viewModel.state.body)
                            .frame(minHeight: 120)
                    }
                    
                    // Submit button
                    Section {
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.submitForm()
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
                        .padding(10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .alert(isPresented: $viewModel.state.showAlert) {
                            Alert(
                                title: Text("Can't Add Point!"),
                                message: Text("There are still missing form values.")
                            )
                        }
                    }
                })
                    .navigationTitle("Add Point")
            }
            .onAppear {
                viewModel.state.location = locationManager.currentLocation
            }
        } else {
            MapView()
        }
    }
}

struct AddPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointView(settingsManager: SettingsManager())
            .environmentObject(SettingsManager())
            .environmentObject(LocationManager(settingsManager: SettingsManager()))
    }
}
