//
//  NetworkSelectorView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SubVTData
import SwiftUI

struct NetworkSelectorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .offset(
                x: 0,
                y: configuration.isPressed ? 1 : 0
            )
            .animation(
                .linear(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

struct NetworkSelectorButtonView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    var isOpen = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            UI.Image.NetworkSelection.networkIcon(network: network)
                .resizable()
            .frame(
                width: UI.Dimension.NetworkStatus.networkIconSize,
                height: UI.Dimension.NetworkStatus.networkIconSize
            )
            Spacer()
                .frame(width: UI.Dimension.NetworkStatus.networkSelectorPadding)
            Text(network.display)
                .font(UI.Font.NetworkStatus.networkSelector)
                .foregroundColor(Color("Text"))
            Spacer()
                .frame(width: UI.Dimension.NetworkStatus.networkSelectorPadding)
            if self.isOpen {
                UI.Image.NetworkStatus.arrowUp(self.colorScheme)
            } else {
                UI.Image.NetworkStatus.arrowDown(self.colorScheme)
            }
        }
        .padding(UI.Dimension.NetworkStatus.networkSelectorPadding)
        .background(Color("NetworkSelectorBg"))
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
}

struct NetworkSelectorButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectorButtonView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
