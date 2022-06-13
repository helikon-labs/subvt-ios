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
            .foregroundColor(Color("ActionButtonText"))
            .background(configuration.isPressed
                        ? Color("ActionButtonPressed")
                        : Color("ActionButton")
            )
            .cornerRadius(10)
            .font(UI.Font.actionButton)
            .offset(
                x: 0,
                y: configuration.isPressed ? 5 : 0
            )
            .shadow(
                color: Color("ActionButtonShadow"),
                radius: 5,
                x: 0,
                y: 10
            )
    }
}

struct ActionButtonDisabledStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(
                width: UI.Dimension.Common.actionButtonWidth,
                height: UI.Dimension.Common.actionButtonHeight
            )
            .foregroundColor(Color("ActionButtonDisabledText"))
            .background(Color("ActionButtonDisabled"))
            .cornerRadius(10)
            .font(UI.Font.actionButton)
    }
}
