//
//  ContentView.swift
//  Geo
//
//  Created by William Svoboda on 10/22/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var count: Int = 0
    
    func incrementCount() {
        count += 1
    }
    
    var body: some View {
        Button(action: incrementCount){
            Text("The count is \(count)").padding().background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 2)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
