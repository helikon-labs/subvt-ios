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
    
    private var bgColor: Color {
        get {
            if let displayType = self.displayType {
                switch displayType {
                case .selector(let isOpen):
                    if isOpen {
                        return Color("NetworkSelectorOpenBg")
                    }
                default:
                    break
                }
            }
            return Color("NetworkSelectorClosedBg")
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            UI.Image.Common.networkIcon(network: network)
                .resizable()
            .frame(
                width: UI.Dimension.Common.networkSelectorIconSize,
                height: UI.Dimension.Common.networkSelectorIconSize
            )
            Spacer()
                .frame(width: UI.Dimension.Common.networkSelectorPadding)
            Text(network.display)
                .font(UI.Font.NetworkStatus.networkSelector)
                .foregroundColor(Color("Text"))
            if self.displayType == DisplayType.selector(isOpen: true) {
                Spacer()
                    .frame(width: UI.Dimension.Common.networkSelectorPadding)
                UI.Image.Common.arrowUp(self.colorScheme)
            } else if self.displayType == .selector(isOpen: false) {
                Spacer()
                    .frame(width: UI.Dimension.Common.networkSelectorPadding)
                UI.Image.Common.arrowDown(self.colorScheme)
            }
        }
        .frame(height: UI.Dimension.Common.networkSelectorHeight)
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.networkSelectorPadding,
            bottom: 0,
            trailing: UI.Dimension.Common.networkSelectorPadding
        ))
        .background(self.bgColor)
        .cornerRadius(UI.Dimension.Common.cornerRadius)
    }
}

struct NetworkSelectorButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectorButtonView(displayType: .selector(isOpen: false))
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
