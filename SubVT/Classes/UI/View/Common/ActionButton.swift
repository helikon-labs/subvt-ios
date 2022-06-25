//
//  ActionButton.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2022.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    @Binding var isEnabled: Bool
    
    private func getBackgroundColor(configuration: Configuration) -> Color {
        if self.isEnabled {
            if configuration.isPressed {
                return Color("ActionButtonPressed")
            } else {
                return Color("ActionButton")
            }
        } else {
            return Color("ActionButtonDisabled")
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                width: UI.Dimension.Common.actionButtonWidth,
                height: UI.Dimension.Common.actionButtonHeight
            )
            .foregroundColor(
                self.isEnabled
                    ? Color("ActionButtonText")
                    : Color("ActionButtonDisabledText")
            )
            .background(self.getBackgroundColor(configuration: configuration))
            .cornerRadius(10)
            .font(UI.Font.Common.actionButton)
            .shadow(
                color: self.isEnabled
                    ? Color("ActionButtonShadow")
                    : Color.clear,
                radius: 5,
                x: 0,
                y: 10
            )
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .offset(
                x: 0,
                y: configuration.isPressed ? 3 : 0
            )
            .animation(
                .easeOut(duration: 0.4),
                value: self.isEnabled
            )
            .animation(
                .linear(duration: 0.10),
                value: configuration.isPressed
            )
    }
}
