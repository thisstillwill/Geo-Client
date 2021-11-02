//
//  ContentView.swift
//  Geo
//
//  Created by William Svoboda on 10/22/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: MapView(), label: {
                Text("Enter")
            })
                .buttonStyle(CircleButton(color: .red))
                .navigationTitle("Welcome")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
