//
//  ActionButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 11.07.2022.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    var state: ActionButtonView.State
    
    private func getScale(configuration: Configuration) -> CGFloat {
        if self.state == .enabled && configuration.isPressed {
            return 0.99
        } else {
            return 1
        }
    }
    
    private func getYOffset(configuration: Configuration) -> CGFloat {
        if self.state == .enabled && configuration.isPressed {
            return 3
        } else {
            return 0
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(self.getScale(configuration: configuration))
            .offset(
                x: 0,
                y: self.getYOffset(configuration: configuration)
            )
            .animation(
                .linear(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

struct ActionButtonView: View {
    enum State {
        case disabled
        case enabled
        case loading
    }
    
    let title: String
    var state: State
    let font: Font
    let width: CGFloat
    let height: CGFloat
    
    init(
        title: String,
        state: State,
        font: Font = UI.Font.Common.actionButton,
        width: CGFloat = UI.Dimension.Common.actionButtonWidth,
        height: CGFloat = UI.Dimension.Common.actionButtonHeight
    ) {
        self.title = title
        self.state = state
        self.font = font
        self.width = width
        self.height = height
    }
    
    private var backgroundColor: Color {
        switch self.state {
        case .enabled, .loading:
            return Color("ActionButtonBg")
        default:
            return Color("ActionButtonBgDisabled")
        }
    }
    
    private var textColor: Color {
        switch self.state {
        case .enabled:
            return Color("ActionButtonText")
        default:
            return Color("ActionButtonDisabledText")
        }
    }
    
    private var shadowColor: Color {
        switch self.state {
        case .disabled:
            return Color.clear
        default:
            return Color("ActionButtonShadow")
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if self.state != .loading {
                Text(title)
                    .font(UI.Font.Common.actionButton)
                    .foregroundColor(self.textColor)
            }
            if self.state == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(
                        tint: Color("ActionButtonText")
                    ))
            }
        }
        .animation(nil, value: self.state)
        .frame(
            width: self.width,
            height: self.height
        )
        .background(self.backgroundColor)
        .cornerRadius(10)
        .shadow(
            color: self.shadowColor,
            radius: 5,
            x: 0,
            y: 10
        )
        .animation(
            .easeOut(duration: 0.4),
            value: self.state
        )
    }
}

struct ActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Button(
            action: {},
            label: {
                ActionButtonView(
                    title: localized("common.go"),
                    state: .enabled
                )
            }
        )
        .buttonStyle(ActionButtonStyle(state: .enabled))
        
    }
}
