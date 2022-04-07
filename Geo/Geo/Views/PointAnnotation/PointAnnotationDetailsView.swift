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
    
    var dateIntervalString: String {
        let timeDifference = Calendar.current.dateComponents([.second], from: point.posted, to: Date.now).second ?? 0
        switch timeDifference {
        case 0..<60:
            return "just now"
        case 60..<120:
            return "1 minute ago"
        case 120..<(60 * 60):
            return "\(Int(timeDifference / 60)) minutes ago"
        case (60 * 60)..<(2 * 60 * 60):
            return "1 hour ago"
        case (2 * 60 * 60)..<(60 * 60 * 24):
            return "\(Int(timeDifference / (60 * 60))) hours ago"
        default:
            return "1 day ago"
        }
    }
    
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
                Text("— \(point.poster) \(dateIntervalString)")
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
        PointAnnotationDetailsView(isPresented: .constant(true), point: TestPoints.dod)
    }
}
