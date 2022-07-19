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
    enum DisplayType: Equatable {
        case display
        case selector(isOpen: Bool)
    }
    
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    var displayType: DisplayType?
    
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
            if self.displayType == DisplayType.selector(isOpen: true) {
                Spacer()
                    .frame(width: UI.Dimension.NetworkStatus.networkSelectorPadding)
                UI.Image.NetworkStatus.arrowUp(self.colorScheme)
            } else if self.displayType == .selector(isOpen: false) {
                Spacer()
                    .frame(width: UI.Dimension.NetworkStatus.networkSelectorPadding)
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
        NetworkSelectorButtonView(displayType: .selector(isOpen: false))
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
