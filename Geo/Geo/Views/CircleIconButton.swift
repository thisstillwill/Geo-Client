//
//  CircleIconButton.swift
//  Geo
//
//  Created by William Svoboda on 3/21/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct CircleIconButton: ButtonStyle {
    
    var foregroundColor: Color
    var backgroundColor: Color
    var fontSize: CGFloat
    var fontWeight: Font.Weight
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: fontWeight))
            .padding()
            .foregroundColor(foregroundColor)
            .background(Circle().fill(backgroundColor))
    }
}
