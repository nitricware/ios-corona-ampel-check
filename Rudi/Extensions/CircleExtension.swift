//
//  CircleExtension.swift
//  Rudi
//
//  Created by Kurt Höblinger on 30.09.20.
//

import SwiftUI

extension Circle {    
    func trafficLight(fillColor: Color, lineColor: Color) -> some View {
        let lineWidth: CGFloat = 5
        let size: CGFloat = 50
        return self
            .fill(fillColor)
            .frame(width: size, height: size)
            .overlay(
                 RoundedRectangle(cornerRadius: size/2)
                    .stroke(lineColor, lineWidth: lineWidth)
            )
    }
}
