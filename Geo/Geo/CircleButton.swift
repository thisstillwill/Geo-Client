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
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 50, weight: .semibold))
            .background(
                ZStack{
                    Circle()
                        .frame(width: 200, height: 200)
                        .foregroundColor(color)
                })
    }
}
