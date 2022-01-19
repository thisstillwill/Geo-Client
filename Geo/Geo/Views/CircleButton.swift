//
//  CircleButton.swift
//  Geo
//
//  Created by William Svoboda on 11/1/21.
//  Copyright © 2021 William Svoboda. All rights reserved.
//

import SwiftUI

struct CircleButton: ButtonStyle {
    
    var color: Color
    var radius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 50, weight: .semibold))
            .background(
                ZStack{
                    Circle()
                        .frame(width: radius, height: radius)
                        .foregroundColor(color)
                })
    }
}
