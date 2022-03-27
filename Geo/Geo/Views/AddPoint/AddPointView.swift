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
    
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var viewModel: AddPointViewModel
    @Binding var isPresented: Bool
    
    private var buttonColor: Color {
        return viewModel.isValid() ? .accentColor : .gray
    }
    
    init (isPresented: Binding<Bool>, location: CLLocationCoordinate2D, settingsManager: SettingsManager) {
        print("Refresh!!!")
        self.viewModel = AddPointViewModel(location: location, settingsManager: settingsManager)
        self._isPresented = isPresented
    }
    
    var body: some View {
        
        NavigationView {
            Form(content: {
                
                // Point information fields
                Section(header: Text("Title")) {
                    TextEditor(text: $viewModel.title)
                        .frame(minHeight: 60)
                    ProgressView("\(viewModel.title.count)/\(settingsManager.maxTitleLength)", value: Double(viewModel.title.count), total: Double(settingsManager.maxTitleLength))
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 240)
                    ProgressView("\(viewModel.description.count)/\(settingsManager.maxDescriptionLength)", value: Double(viewModel.description.count), total: Double(settingsManager.maxDescriptionLength))
                }
                
                // Submit button
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.submitForm()
                                if (viewModel.state.hasSubmitted) {
                                    isPresented = false
                                }
                            } catch {
                                viewModel.state.showAlert = true
                                viewModel.state.alertTitle = "Submission error!"
                                viewModel.state.alertMessage = "Unable to connect to the server."
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Submit")
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValid())
                    .foregroundColor(.white)
                    .padding(8)
                    .background(buttonColor)
                    .cornerRadius(8)
                    .listRowBackground(buttonColor)
                }
            })
                .navigationTitle("Add Point")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    }
                }
                .alert(isPresented: $viewModel.state.showAlert) {
                    Alert(
                        title: Text(viewModel.state.alertTitle),
                        message: Text(viewModel.state.alertMessage)
                    )
                }
        }
    }
}

struct AddPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointView(isPresented: .constant(true), location: CLLocationCoordinate2D(latitude: 0.000, longitude: 0.000), settingsManager: SettingsManager()).environmentObject(SettingsManager())
    }
}
