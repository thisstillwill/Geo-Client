//
//  AddPointView.swift
//  Geo
//
//  Created by William Svoboda on 1/18/22.
//  Copyright © 2022 William Svoboda. All rights reserved.
//

import SwiftUI

struct AddPointView: ButtonStyle {
    
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 50, weight: .semibold))
            .background(
                ZStack{
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                })
    }
}
