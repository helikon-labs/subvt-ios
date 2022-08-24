//
//  NetworkSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.06.2022.
//

import SubVTData
import SwiftUI

struct NetworkSelectionView: View {
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @AppStorage(AppStorageKey.selectedNetwork) private var appSelectedNetwork: Network? = nil
    @StateObject private var viewModel = NetworkSelectionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var networksDisplayState: BasicViewDisplayState = .notAppeared
    @State private var actionButtonState: ActionButtonView.State = .disabled
    @State private var selectedNetwork: Network! = nil
    
    private let gridItemLayout = [
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize)),
        GridItem(.fixed(UI.Dimension.NetworkSelection.networkButtonSize))
    ]
    
    private func onGetNetworksSuccess(networks: [Network]) {
        self.networks = networks
    }
    
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
                .offset(y: UI.Dimension.NetworkSelection.topTextGroupOffset(
                    displayState: self.displayState
                ))
                .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                .animation(
                    .easeOut(duration: 0.5),
                    value: self.displayState
                )
                Spacer()
                    .frame(height: UI.Dimension.NetworkSelection.networkGridMarginTop)
                ZStack(alignment: .center) {
                    Color("Bg")
                    switch self.viewModel.fetchState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: Color("Text")
                                )
                            )
                            .scaleEffect(1.25)
                    case .success(let networks):
                        LazyVGrid(
                            columns: self.gridItemLayout,
                            spacing: UI.Dimension.NetworkSelection.networkButtonSpacing
                        ) {
                            ForEach(networks.indices, id: \.self) { i in
                                Button(
                                    action: {
                                        self.selectedNetwork = networks[i]
                                        self.actionButtonState = .enabled
                                    },
                                    label: {
                                        NetworkButtonView(
                                            isSelected: self.selectedNetwork?.id == networks[i].id,
                                            network: networks[i]
                                        )
                                    }
                                )
                                .buttonStyle(NetworkButtonStyle())
                                .zIndex(100 - Double(i))
                            }
                        }
                        .offset(y: UI.Dimension.NetworkSelection.networkButtonYOffset(
                            displayState: self.networksDisplayState
                        ))
                        .opacity(UI.Dimension.Common.displayStateOpacity(
                            self.networksDisplayState
                        ))
                        .animation(
                            .easeOut(duration: 0.4),
                            value: self.networksDisplayState
                        )
                        .onAppear {
                            self.networksDisplayState = .appeared
                        }
                    default:
                        Spacer()
                    }
                }
                .frame(height: UI.Dimension.NetworkSelection.networkButtonSize)
                .animation(.easeOut(duration: 0.5), value: self.viewModel.fetchState)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Spacer()
                        .frame(height: UI.Dimension.Common.actionButtonMarginTop)
                } else {
                    Spacer()
                }
                VStack(alignment: .center) {
                    Button(
                        action: {
                            guard let network = selectedNetwork else {
                                return
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.displayState = .dissolved
                                self.networksDisplayState = .dissolved
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.appSelectedNetwork = network
                                }
                            }
                        },
                        label: {
                            ActionButtonView(
                                title: localized("common.go"),
                                state: self.actionButtonState
                            )
                        }
                    )
                    .buttonStyle(ActionButtonStyle(state: self.actionButtonState))
                    .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
                    .offset(
                        x: 0,
                        y: UI.Dimension.Common.actionButtonYOffset(
                            displayState: self.displayState
                        )
                    )
                    .animation(
                        .easeOut(duration: 0.5),
                        value: self.displayState
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
            ZStack {
                SnackbarView(
                    message: localized("network_selection.error.network_list"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.fetchNetworks(
                        storedNetworks: self.networks,
                        onSuccess: self.onGetNetworksSuccess
                    )
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(
                    y: UI.Dimension.NetworkSelection.snackbarYOffset(
                        fetchState: self.viewModel.fetchState
                    )
                )
                .opacity(UI.Dimension.NetworkSelection.snackbarOpacity(
                    fetchState: self.viewModel.fetchState
                ))
                .animation(
                    .spring(),
                    value: self.viewModel.fetchState
                )
            }
        }
        .onAppear {
            self.displayState = .appeared
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.viewModel.fetchNetworks(
                    storedNetworks: self.networks,
                    onSuccess: self.onGetNetworksSuccess
                )
            }
        }
    }
}

struct NetworkSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectionView()
            // .preferredColorScheme(.dark)
    }
}
