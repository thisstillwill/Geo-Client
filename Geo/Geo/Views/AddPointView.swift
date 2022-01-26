//
//  AddPointView.swift
//  Geo
//
//  Created by William Svoboda on 1/25/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct AddPointView: View {
    
    @State var title: String = ""
    
    var body: some View {
        NavigationView {
            Form(content: {
                
                // Point information
                Section(header: Text("Information")) {
                    TextField("Title", text: $title)
                }
                
                // Submit button
                Section {
                    Button(action: {
                        // Do something!
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
