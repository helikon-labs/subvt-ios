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
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                UI.Image.Common.networkIcon(network: network)
                    .resizable()
                    .frame(
                        width: UI.Dimension.NetworkStatus.networkSelectorIconSize,
                        height: UI.Dimension.NetworkStatus.networkSelectorIconSize
                    )
                Spacer()
                if isSelected {
                    Circle()
                        .fill(Color("ItemListSelectionIndicator"))
                        .frame(
                            width: UI.Dimension.Common.itemSelectionIndicatorSize,
                            height: UI.Dimension.Common.itemSelectionIndicatorSize
                        )
                        .shadow(
                            color: Color("ItemListSelectionIndicator"),
                            radius: 3,
                            x: 0,
                            y: UI.Dimension.Common.itemSelectionIndicatorSize / 2
                        )
                        .animation(.linear(duration: 0.1), value: self.isSelected)
                }
            }
            Spacer()
                .frame(height: 24)
            Text(network.display)
                .font(UI.Font.NetworkStatus.network)
                .foregroundColor(Color("Text"))
        }
        .padding(UI.Dimension.Common.dataPanelPadding)
        .frame(height: UI.Dimension.NetworkStatus.networkButtonHeight)
        .frame(maxWidth: .infinity)
        .background(Color("DataPanelBg"))
        .cornerRadius(UI.Dimension.Common.dataPanelCornerRadius)
    }
}
