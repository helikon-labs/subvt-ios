//
//  NetworkStatusView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SubVTData
import SwiftUI

struct NetworkStatusView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @StateObject private var viewModel = NetworkStatusViewModel()
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @State private var networkSelectorIsOpen = false
    
    var body: some View {
        VStack {
            ZStack() {
                VStack {
                    Spacer()
                        .frame(height: UI.Dimension.NetworkStatus.titleMarginTop)
                    HStack(alignment: .center) {
                        HStack(alignment: .top, spacing: 0) {
                            Text(LocalizedStringKey("network_status.title"))
                                .font(UI.Font.NetworkStatus.title)
                                .foregroundColor(Color("Text"))
                            Spacer()
                                .frame(width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft)
                            Circle()
                                .frame(
                                    width: UI.Dimension.NetworkStatus.connectionStatusSize,
                                    height: UI.Dimension.NetworkStatus.connectionStatusSize
                                )
                                .foregroundColor(viewModel.networkStatusServiceStatus.color)
                        }
                        Spacer()
                        Button(
                            action: {
                                self.networkSelectorIsOpen.toggle()
                            },
                            label: {
                                NetworkSelectorButtonView(
                                    network: self.network,
                                    isOpen: networkSelectorIsOpen
                                )
                            }
                        )
                        .buttonStyle(NetworkSelectorButtonStyle())
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .zIndex(1)
                ScrollView {
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .frame(height: UI.Dimension.NetworkStatus.scrollContentMarginTop)
                        HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                            Button(
                                action: {
                                    print("Go to active validator list.")
                                },
                                label: {
                                    ValidatorListButtonView(
                                        title: LocalizedStringKey("active_validator_list.title"),
                                        count: self.viewModel.networkStatus.activeValidatorCount
                                    )
                                }
                            )
                            .buttonStyle(ValidatorListButtonStyle())
                            Button(
                                action: {
                                    print("Go to inactive validator list.")
                                },
                                label: {
                                    ValidatorListButtonView(
                                        title: LocalizedStringKey("inactive_validator_list.title"),
                                        count: self.viewModel.networkStatus.inactiveValidatorCount
                                    )
                                }
                            )
                            .buttonStyle(ValidatorListButtonStyle())
                        }
                        BlockNumberView(
                            title: LocalizedStringKey("network_status.best_block_number"),
                            blockNumber: self.viewModel.networkStatus.bestBlockNumber
                        )
                        HStack (spacing: UI.Dimension.Common.dataPanelSpacing) {
                            EraEpochView(eraOrEpoch: .left(self.viewModel.networkStatus.activeEra))
                            EraEpochView(eraOrEpoch: .right(self.viewModel.networkStatus.currentEpoch))
                        }
                    }
                }
                .zIndex(0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            self.viewModel.subscribeToNetworkStatus(network: network)
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(newPhase)
        }
    }
}

struct NetworkStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkStatusView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
