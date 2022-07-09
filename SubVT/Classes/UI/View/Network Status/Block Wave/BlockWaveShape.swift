//
//  BlockWaveShape.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.07.2022.
//

import SwiftUI

struct BlockWaveShape: Shape {
    let parameters: BlockWaveParameters
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var waveHeight = self.parameters.amplitude * rect.height
        if self.parameters.progress <= 0.5 {
            waveHeight = self.parameters.progress / 0.5 * waveHeight
        } else {
            waveHeight = waveHeight - (self.parameters.progress - 0.5) / 0.5 * waveHeight
        }
        let yoffset = CGFloat(1 - self.parameters.progress) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = self.parameters.offset
        let endAngle = self.parameters.offset + Angle(degrees: 360)
        path.move(to: CGPoint(
            x: 0,
            y: yoffset + waveHeight * CGFloat(sin(self.parameters.offset.radians))
        ))
        for angle in stride(
            from: startAngle.degrees,
            through: endAngle.degrees,
            by: 5
        ) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            path.addLine(
                to: CGPoint(
                    x: x,
                    y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))
                )
            )
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
