//
//  ActionButton.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2022.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    @Binding var isEnabled: Bool
    
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
            .background(
                self.isEnabled
                    ? (
                        configuration.isPressed
                            ? Color("ActionButtonPressed")
                            : Color("ActionButton")
                    )
                    : Color("ActionButtonDisabled")
            )
            .cornerRadius(10)
            .font(UI.Font.actionButton)
            .offset(
                x: 0,
                y: configuration.isPressed ? 3 : 0
            )
            .shadow(
                color: self.isEnabled
                    ? Color("ActionButtonShadow")
                    : Color.clear,
                radius: 5,
                x: 0,
                y: 10
            )
            .animation(
                .easeOut(duration: 0.5),
                value: self.isEnabled
            )
            .animation(
                .linear(duration: 0.10),
                value: configuration.isPressed
            )
    }
}
