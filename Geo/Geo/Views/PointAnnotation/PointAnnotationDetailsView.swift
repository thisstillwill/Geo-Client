//
//  PointAnnotationDetailsView.swift
//  Geo
//
//  Created by William Svoboda on 2/6/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct PointAnnotationDetailsView: View {
    
    @Binding var isPresented: Bool
    
    let point: Point
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(String(format: "%.3f, %.3f", point.location.latitude, point.location.longitude))
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(point.title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                Text(point.body)
                    .font(.body)
                    .fontWeight(.regular)
                Text("Posted by \(point.poster)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
            .navigationTitle("Point Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct PointAnnotationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PointAnnotationDetailsView(isPresented: .constant(true), point: TestPoints.lot19)
    }
}
