//
//  NetworkStatusView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import Combine
import SubVTData
import SwiftUI

fileprivate var avgBlockTimeSec = 6.0
fileprivate var blockWaveMaxOffsetDegrees = -1440.0
fileprivate var blockTimerStartTimeSec = 0.0
fileprivate let blockTimerPeriodSec = 0.01
fileprivate let blockWaveAmplitudeRange = 0.05...0.1
fileprivate var currentBlockWaveAmplitude = blockWaveAmplitudeRange.lowerBound

struct NetworkStatusView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @StateObject private var viewModel = NetworkStatusViewModel()
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @State private var networkSelectorIsOpen = false
    @State private var blockTimerSubscription: Cancellable?
    @State private var blockTimer = Timer.publish(every: blockTimerPeriodSec, on: .main, in: .common)
    @State private var blockWaveParameters = BlockWaveParameters(
        offset: Angle(degrees: 0),
        progress: 0.0,
        amplitude: currentBlockWaveAmplitude
    )
    
    func onNetworkStatusUpdate() {
        blockTimerStartTimeSec = Date().timeIntervalSince1970
        blockWaveMaxOffsetDegrees = -Double.random(in: 1000...1500)
        currentBlockWaveAmplitude = Double.random(in: blockWaveAmplitudeRange)
        self.startBlockTimer()
    }
    
    private func startBlockTimer() {
        guard self.blockTimerSubscription == nil else {
            return
        }
        self.blockTimer = Timer.publish(every: blockTimerPeriodSec, on: .main, in: .common)
        self.blockTimerSubscription = self.blockTimer.connect()
        blockTimerStartTimeSec = Date().timeIntervalSince1970
    }
    
    private func cancelBlockTimer() {
        self.blockTimerSubscription?.cancel()
        self.blockTimerSubscription = nil
    }
    
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
                                .frame(width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft.get())
                            Circle()
                                .frame(
                                    width: UI.Dimension.NetworkStatus.connectionStatusSize.get(),
                                    height: UI.Dimension.NetworkStatus.connectionStatusSize.get()
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
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.padding
                ))
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
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            BlockNumberView(
                                title: LocalizedStringKey("network_status.best_block_number"),
                                blockNumber: self.viewModel.networkStatus.bestBlockNumber,
                                blockWaveParameters: self.blockWaveParameters
                            )
                            BlockNumberView(
                                title: LocalizedStringKey("network_status.finalized_block_number"),
                                blockNumber: self.viewModel.networkStatus.finalizedBlockNumber
                            )
                        } else {
                            HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                BlockNumberView(
                                    title: LocalizedStringKey("network_status.best_block_number"),
                                    blockNumber: self.viewModel.networkStatus.bestBlockNumber,
                                    blockWaveParameters: self.blockWaveParameters
                                )
                                BlockNumberView(
                                    title: LocalizedStringKey("network_status.finalized_block_number"),
                                    blockNumber: self.viewModel.networkStatus.finalizedBlockNumber
                                )
                            }
                        }
                        HStack (spacing: UI.Dimension.Common.dataPanelSpacing) {
                            EraEpochView(eraOrEpoch: .left(self.viewModel.networkStatus.activeEra))
                            EraEpochView(eraOrEpoch: .right(self.viewModel.networkStatus.currentEpoch))
                        }
                        HStack (spacing: UI.Dimension.Common.dataPanelSpacing) {
                            EraPointsBlocksProducedView(
                                title: localized("network_status.era_points"),
                                value: self.viewModel.networkStatus.eraRewardPoints,
                                myValidatorsValue: nil
                            )
                            EraPointsBlocksProducedView(
                                title: localized("network_status.number_of_blocks"),
                                value: 0,
                                myValidatorsValue: nil
                            )
                        }
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            LastEraTotalRewardView(
                                network: self.network,
                                reward: self.viewModel.networkStatus.lastEraTotalReward
                            )
                            ValidatorBackingsView(
                                minimum: self.viewModel.networkStatus.minStake,
                                maximum: self.viewModel.networkStatus.maxStake,
                                average: self.viewModel.networkStatus.averageStake
                            )
                        } else {
                            HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                LastEraTotalRewardView(
                                    network: self.network,
                                    reward: self.viewModel.networkStatus.lastEraTotalReward
                                )
                                ValidatorBackingsView(
                                    minimum: self.viewModel.networkStatus.minStake,
                                    maximum: self.viewModel.networkStatus.maxStake,
                                    average: self.viewModel.networkStatus.averageStake
                                )
                            }
                        }
                        Spacer()
                            .frame(height: UI.Dimension.NetworkStatus.scrollContentMarginBottom)
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
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
            self.viewModel.subscribeToNetworkStatus(
                network: network,
                self.onNetworkStatusUpdate
            )
        }
        .onReceive(blockTimer) { _ in
            let elapsedSec = Date().timeIntervalSince1970 - blockTimerStartTimeSec
            let progress = elapsedSec  / avgBlockTimeSec
            self.blockWaveParameters = BlockWaveParameters(
                offset: Angle(degrees: blockWaveMaxOffsetDegrees * progress),
                progress: progress,
                amplitude: currentBlockWaveAmplitude
            )
        }
        .onChange(of: scenePhase) { newPhase in
            self.viewModel.onScenePhaseChange(
                newPhase,
                self.onNetworkStatusUpdate
            )
            switch newPhase {
            case .background:
                break
            case .inactive:
                self.cancelBlockTimer()
            case .active:
                break
            @unknown default:
                fatalError("Unknown scene phase: \(scenePhase)")
            }
        }
    }
}

struct NetworkStatusView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkStatusView()
            .defaultAppStorage(PreviewData.userDefaults)
    }
}
