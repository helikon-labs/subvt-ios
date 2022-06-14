//
//  ActionButton.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2022.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                width: UI.Dimension.Common.actionButtonWidth,
                height: UI.Dimension.Common.actionButtonHeight
            )
            .foregroundColor(isEnabled ? Color("ActionButtonText") : Color("ActionButtonDisabledText"))
            .background(isEnabled
                ? (configuration.isPressed ? Color("ActionButtonPressed") : Color("ActionButton"))
                : Color("ActionButtonDisabled")
            )
            .cornerRadius(10)
            .font(UI.Font.actionButton)
            .offset(
                x: 0,
                y: configuration.isPressed ? 5 : 0
            )
            .animation(
                .easeOut(duration: 0.15),
                value: configuration.isPressed
            )
            .shadow(
                color: isEnabled
                    ? Color("ActionButtonShadow")
                    : Color.clear,
                radius: 5,
                x: 0,
                y: 10
            )
    }
}
