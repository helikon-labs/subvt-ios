//
//  NetworkSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.06.2022.
//

import SwiftUI

struct NetworkSelectionView: View {
    @EnvironmentObject var appData: AppData
    @StateObject private var viewModel = NetworkSelectionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    
    private let gridItemLayout = [
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize)),
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize))
    ]
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color("Bg").ignoresSafeArea()
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: UI.Dimension.NetworkSelection.titleMarginTop)
                Group {
                    Text(LocalizedStringKey("network_selection.selected_network"))
                        .font(UI.Font.NetworkSelection.title)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(height: UI.Dimension.NetworkSelection.subtitleMarginTop)
                    Text(LocalizedStringKey("network_selection.select_network"))
                        .font(UI.Font.NetworkSelection.subtitle)
                        .foregroundColor(Color("Text"))
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Onboarding.textHorizontalPadding,
                    bottom: 0,
                    trailing: UI.Dimension.Onboarding.textHorizontalPadding
                ))
                Spacer()
                    .frame(height: UI.Dimension.NetworkSelection.networkGridMarginTop)
                ZStack(alignment: .center) {
                    Color("Bg")
                    switch viewModel.fetchState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("Text")))
                            .scaleEffect(1.25)
                    case .success(let networks):
                        LazyVGrid(
                            columns: self.gridItemLayout,
                            spacing: UI.Dimension.NetworkSelection.networkButtonSpacing
                        ) {
                            ForEach(networks.indices, id: \.self) { i in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(
                                        cornerRadius: UI.Dimension.NetworkSelection.networkButtonCornerRadius,
                                        style: .circular
                                    )
                                    .fill(Color("NetworkButtonBg"))
                                    .frame(
                                        width: UI.Dimension.NetworkSelection.networkButtonSize,
                                        height: UI.Dimension.NetworkSelection.networkButtonSize
                                    )
                                    .shadow(
                                        color: Color("NetworkButtonShadow"),
                                        radius: 8,
                                        x: UI.Dimension.NetworkSelection.networkButtonShadowOffset,
                                        y: UI.Dimension.NetworkSelection.networkButtonShadowOffset
                                    )
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .top) {
                                            UI.Image.NetworkSelection.networkIcon(network: networks[i])
                                                .frame(
                                                    width: UI.Dimension.NetworkSelection.networkIconSize,
                                                    height: UI.Dimension.NetworkSelection.networkIconSize
                                                )
                                            Spacer()
                                            Circle()
                                                .fill(Color.green)
                                                .frame(
                                                    width: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize,
                                                    height: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize
                                                )
                                                .shadow(
                                                    color: Color.green,
                                                    radius: 3,
                                                    x: 0,
                                                    y: UI.Dimension.NetworkSelection.networkSelectionIndicatorSize / 2
                                                )
                                        }
                                        Spacer()
                                        Text(networks[i].display)
                                            .font(UI.Font.NetworkSelection.network)
                                            .foregroundColor(Color("Text"))
                                    }
                                    .padding(UI.Dimension.NetworkSelection.networkButtonPadding)
                                }
                                .zIndex(100 - Double(i))
                                .padding(0)
                            }
                        }
                    default:
                        Spacer()
                    }
                }
                .frame(height: UI.Dimension.NetworkSelection.networkButtonSize)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginTop)
                } else {
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Button(LocalizedStringKey("common.go")) {
                        // action
                    }
                    .disabled(appData.network == nil)
                    .buttonStyle((appData.network == nil)
                                 ? ActionButtonDisabledStyle()
                                 : ActionButtonDisabledStyle()
                    )
                }
                .frame(maxWidth: .infinity)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                } else {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginBottom)
                }
            }
        }
        .onAppear {
            self.viewModel.getNetworks()
        }
    }
}

struct NetworkSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectionView()
    }
}
