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
    
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var locationManager: LocationManager
    
    let point: Point
    
    var body: some View {
        if (locationManager.inRange(otherLocation: point.location)) {
            NavigationLink {
                PointAnnotationDetailsView(point: point)
            } label: {
                PointAnnotationIconView(accent: settingsManager.inRangeColor)
            }
        } else {
            PointAnnotationIconView(accent: settingsManager.notInRangeColor)
        }
    }
}

struct PointAnnotationIconView: View {
    
    let accent: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, accent, accent)
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundColor(accent)
                .offset(x: 0, y: -5)
        }
    }
}

struct PointAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        PointAnnotationView(point: TestPoints.lot19)
            .environmentObject(SettingsManager())
            .environmentObject(LocationManager(settingsManager: SettingsManager()))
    }
}
