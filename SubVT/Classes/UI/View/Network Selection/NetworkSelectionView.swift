//
//  NetworkSelectionView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.06.2022.
//

import SwiftUI
import SubVTData

struct NetworkSelectionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = NetworkSelectionViewModel()
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var networksDisplayState: BasicViewDisplayState = .notAppeared
    @State private var selectedNetwork: Network? = nil
    @State private var actionButtonIsEnabled = false
    
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
                                        self.actionButtonIsEnabled = true
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
                VStack(alignment: .leading) {
                    Button(LocalizedStringKey("common.go")) {
                        guard let network = selectedNetwork else {
                            return
                        }
                        self.displayState = .dissolved
                        self.networksDisplayState = .dissolved
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.viewModel.selectNetwork(
                                appState: self.appState,
                                network: network
                            )
                        }
                    }
                    .disabled(selectedNetwork == nil)
                    .buttonStyle(ActionButtonStyle(isEnabled: $actionButtonIsEnabled))
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
                    message: LocalizedStringKey("network_selection.error.network_list"),
                    type: .error(canRetry: true)
                ) {
                    self.viewModel.getNetworks()
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
                self.viewModel.getNetworks()
            }
        }
    }
}

struct NetworkSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkSelectionView()
            .environmentObject(AppState())
            // .preferredColorScheme(.dark)
    }
}
