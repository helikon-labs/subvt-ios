//
//  NetworkButtonView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 14.06.2022.
//

import SwiftUI
import SubVTData

struct NetworkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}

struct NetworkButtonView: View {
    let isSelected: Bool
    let network: Network
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(
                cornerRadius: UI.Dimension.Common.cornerRadius,
                style: .circular
            )
            .fill(Color("NetworkButtonBg"))
            .frame(
                width: UI.Dimension.NetworkSelection.networkButtonSize,
                height: UI.Dimension.NetworkSelection.networkButtonSize
            )
            .shadow(
                color: isSelected
                    ? Color("NetworkButtonShadow")
                    : Color.clear,
                radius: 16,
                x: UI.Dimension.NetworkSelection.networkButtonShadowOffset,
                y: UI.Dimension.NetworkSelection.networkButtonShadowOffset
            )
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    UI.Image.NetworkSelection.networkIcon(network: network)
                        .frame(
                            width: UI.Dimension.NetworkSelection.networkIconSize,
                            height: UI.Dimension.NetworkSelection.networkIconSize
                        )
                    Spacer()
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color("NetworkButtonSelectionIndicator"))
                                .frame(
                                    width: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize,
                                    height: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize
                                )
                                .shadow(
                                    color: Color("NetworkButtonSelectionIndicator"),
                                    radius: 3,
                                    x: 0,
                                    y: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize / 2
                                )
                        }
                    }
                    .animation(.linear(duration: 0.1), value: self.isSelected)
                }
                Spacer()
                Text(network.display)
                    .font(UI.Font.NetworkSelection.network)
                    .foregroundColor(Color("Text"))
            }
            .padding(UI.Dimension.NetworkSelection.networkButtonPadding)
        }
        .frame(
            width: UI.Dimension.NetworkSelection.networkButtonSize,
            height: UI.Dimension.NetworkSelection.networkButtonSize
        )
    }
}

struct NetworkButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkButtonView(
            isSelected: true,
            network: PreviewData.kusama
        )
    }
}
