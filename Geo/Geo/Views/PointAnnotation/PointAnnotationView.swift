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
    
    @StateObject var viewModel: PointAnnotationViewModel
    
    let point: Point
    
    var body: some View {
        if (viewModel.canInteract(otherLocation: point.location)) {
            Button(action: {
                viewModel.showPointDetailsView.toggle()
            }) {
                PointAnnotationIconView(accent: viewModel.inRangeColor)
            }
            .sheet(isPresented: $viewModel.showPointDetailsView) {
                PointAnnotationDetailsView(isPresented: $viewModel.showPointDetailsView, point: point)
            }
        } else {
            PointAnnotationIconView(accent: viewModel.notInRangeColor)
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
        PointAnnotationView(viewModel: PointAnnotationViewModel(settingsManager: SettingsManager(), locationManager: LocationManager(settingsManager: SettingsManager())), point: TestPoints.lot19)
    }
}
