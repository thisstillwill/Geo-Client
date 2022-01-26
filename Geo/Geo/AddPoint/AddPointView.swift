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
    
    @StateObject private var viewModel = AddPointViewModel()
    
    var body: some View {
        NavigationView {
            Form(content: {
                
                // Point information
                Section(header: Text("Information")) {
                    TextField("Title", text: $viewModel.state.title)
                }
                
                // Submit button
                Section {
                    Button(action: viewModel.submitForm) {
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
    }
}

struct AddPointView_Previews: PreviewProvider {
    static var previews: some View {
        AddPointView()
    }
}
