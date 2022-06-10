//
//  ActionButton.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2022.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                width: UI.Dimension.Common.actionButtonWidth,
                height: UI.Dimension.Common.actionButtonHeight
            )
            .foregroundColor(UI.Color.Common.actionButtonText)
            .background(configuration.isPressed
                        ? UI.Color.Common.actionButtonPressed
                        : UI.Color.Common.actionButton
            )
            .cornerRadius(10)
            .font(UI.Font.actionButton)
            .offset(
                x: 0,
                y: configuration.isPressed ? 5 : 0
            )
            .shadow(
                color: UI.Color.Common.actionButtonShadow,
                radius: 10,
                x: 0,
                y: 10
            )
            .animation(.easeOut(duration: 0.2))
    }
}
