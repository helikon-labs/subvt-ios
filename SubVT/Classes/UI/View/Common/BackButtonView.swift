//
//  BackButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SwiftUI

struct BackButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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

struct BackButtonView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    
    var body: some View {
        UI.Image.Common.backArrow(self.colorScheme)
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Button(
            action: {},
            label: {
                BackButtonView()
            }
        )
        .buttonStyle(BackButtonStyle())
    }
}
