//
//  CircleIconButton.swift
//  Geo
//
//  Created by William Svoboda on 3/21/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct CircleButton: ButtonStyle {
    
    var foregroundColor: Color
    var backgroundColor: Color
    var radius: CGFloat
    var fontSize: CGFloat
    var fontWeight: Font.Weight
    
    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: radius, height: radius, alignment: .center)
            .overlay(configuration.label
                        .foregroundColor(foregroundColor)
                        .font(.system(size: fontSize, weight: fontWeight))
            )
    }
}
