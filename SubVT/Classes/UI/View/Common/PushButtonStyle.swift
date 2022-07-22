//
//  PushButtonStyle.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.07.2022.
//

import SwiftUI

struct PushButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .offset(
                x: 0,
                y: configuration.isPressed ? 2 : 0
            )
            .animation(
                .linear(duration: 0.1),
                value: configuration.isPressed
            )
    }
}
