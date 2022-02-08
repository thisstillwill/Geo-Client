//
//  PointAnnotationDetailsView.swift
//  Geo
//
//  Created by William Svoboda on 2/6/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct PointAnnotationDetailsView: View {
    
    let point: Point
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(String(format: "%.4f, %.4f", point.location.latitude, point.location.longitude))
                .font(.headline)
                .foregroundColor(.secondary)
            Text(point.title)
                .font(.title)
                .fontWeight(.black)
            Text(point.body)
                .font(.body)
                .fontWeight(.regular)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

struct PointAnnotationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PointAnnotationDetailsView(point: TestPoints.lot19)
    }
}
