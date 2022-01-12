//
//  PointAnnotationView.swift
//  Geo
//
//  Created by William Svoboda on 1/12/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI
import MapKit

struct PointAnnotationView: View {
    
    // TODO: Only one open annotation at a time
    @State private var showTitle = true
    
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.callout)
                .padding(5)
                .background(Color(.white))
                .cornerRadius(10)
                .opacity(showTitle ? 0 : 1)
            
            // TODO: Change annotation design?
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                showTitle.toggle()
            }
        }
    }
}

struct PointAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PointAnnotationView(title: "Hello, Point!")
    }
}
