//
//  LinearGradientProgressViewStyle.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.07.2022.
//

import SwiftUI

struct LinearGradientProgressViewStyle: ProgressViewStyle {
    
    private func getGradientWidth(
        fractionCompleted: Double,
        totalWidth: CGFloat
    ) -> CGFloat {
        switch fractionCompleted {
        case 0...0.3:
            return totalWidth * fractionCompleted / 3
        case 0.7...1:
            return totalWidth * (1.0 - fractionCompleted) / 2
        default:
            return totalWidth * 0.1
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0.0
        GeometryReader { metrics in
            let gradientWidth = getGradientWidth(
                fractionCompleted: fractionCompleted,
                totalWidth: metrics.size.width
            )
            let progressWidth = metrics.size.width * fractionCompleted - gradientWidth / 2
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color("Progress"))
                    .frame(width: progressWidth)
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color("Progress"),
                                Color("StatusActive")
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: gradientWidth)
                Rectangle()
                    .fill(Color("StatusActive"))
            }
        }
    }
}
