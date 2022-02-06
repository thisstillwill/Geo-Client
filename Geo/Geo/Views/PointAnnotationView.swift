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
    
    var body: some View {
        VStack(spacing: 0) {
            // TODO: Change annotation design?
            Image(systemName: "mappin.circle.fill")
                .renderingMode(.original)
                .font(.title)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: 0, y: -5)
        }
    }
}

struct PointAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PointAnnotationView()
    }
}
