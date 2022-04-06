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
    
    @StateObject var viewModel: AddPointViewModel
    
    private var buttonColor: Color {
        return viewModel.isValid() ? .accentColor : .gray
    }
    
    var body: some View {
        NavigationView {
            Form(content: {
                // Point information fields
                Section(header: Text("Title")) {
                    TextEditor(text: $viewModel.title)
                        .frame(minHeight: 60)
                    ProgressView("\(viewModel.title.count)/\(viewModel.maxTitleLength)", value: Double(viewModel.title.count), total: Double(viewModel.maxTitleLength))
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $viewModel.description)
                        .frame(minHeight: 240)
                    ProgressView("\(viewModel.description.count)/\(viewModel.maxDescriptionLength)", value: Double(viewModel.description.count), total: Double(viewModel.maxDescriptionLength))
                }
                // Submit button
                Section {
                    Button(action: {
                        Task {
                            await viewModel.submitForm()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.submittingPoint {
                                ProgressView()
                            } else {
                                Text("Submit")
                            }
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
                        viewModel.isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
                )
            }
        }
    }
}

struct AddPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointView(viewModel: AddPointViewModel(isPresented: .constant(true), location: CLLocationCoordinate2D(latitude: 0.000, longitude: 0.000), settingsManager: SettingsManager(), authenticationManager: AuthenticationManager(settingsManager: SettingsManager())))
    }
}
