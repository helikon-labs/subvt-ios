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
    @StateObject private var networkMonitor = NetworkMonitor()
    @AppStorage(AppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    @AppStorage(AppStorageKey.apnsIsEnabled) var apnsIsEnabled = false
    @AppStorage(AppStorageKey.hasCompletedAPNSRegistration) private var hasCompletedAPNSRegistration = false
    @State private var displayState: BasicViewDisplayState = .notAppeared
    @State private var headerMaterialOpacity = 0.0
    @State private var networkSelectorIsOpen = false
    @State private var blockTimerSubscription: Cancellable?
    @State private var blockTimer = Timer.publish(
        every: blockTimerPeriodSec,
        on: .main,
        in: .common
    )
    @State private var blockWaveParameters = BlockWaveParameters(
        offset: Angle(degrees: 0),
        progress: 0.0,
        amplitude: currentBlockWaveAmplitude
    )
    @State private var isAnimated: Bool = true
    @State private var changeNetworkDebounce: Timer? = nil
    
    func onNetworkStatusReceived() {
        self.startBlockTimer()
        self.viewModel.fetchEraValidatorCounts(
            currentEraIndex: self.viewModel.networkStatus.activeEra.index
        )
    }
    
    func onNetworkStatusDiffReceived() {
        self.cancelBlockTimer()
        self.startBlockTimer()
    }
    
    private func startBlockTimer() {
        guard self.blockTimerSubscription == nil else {
            return
        }
        blockTimerStartTimeSec = Date().timeIntervalSince1970
        blockWaveMaxOffsetDegrees = -Double.random(in: 1000...1500)
        currentBlockWaveAmplitude = Double.random(in: blockWaveAmplitudeRange)
        self.blockTimer = Timer.publish(
            every: blockTimerPeriodSec,
            on: .main,
            in: .common
        )
        self.blockTimerSubscription = self.blockTimer.connect()
    }
    
    private func cancelBlockTimer() {
        self.blockTimerSubscription?.cancel()
        self.blockTimerSubscription = nil
    }
    
    private var headerView: some View {
        VStack {
            Spacer()
                .frame(height: UI.Dimension.Common.titleMarginTop)
            HStack(alignment: .center) {
                HStack(alignment: .top, spacing: 0) {
                    Text(localized("network_status.title"))
                        .font(UI.Font.Common.tabViewTitle)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(
                            width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft.get()
                        )
                    WSRPCStatusIndicatorView(
                        status: self.viewModel.networkStatusServiceStatus,
                        isConnected: self.networkMonitor.isConnected,
                        size: UI.Dimension.Common.connectionStatusSize.get()
                    )
                    //.modifier(PanelAppearance(5, self.displayState))
                }
                .modifier(PanelAppearance(0, self.displayState))
                Spacer()
                Button(
                    action: {
                        self.networkSelectorIsOpen.toggle()
                    },
                    label: {
                        NetworkSelectorButtonView(
                            network: self.network,
                            displayType: .selector(isOpen: false)
                        )
                        .opacity(self.networkSelectorIsOpen ? 0 : 1)
                    }
                )
                .buttonStyle(NetworkSelectorButtonStyle())
                .modifier(PanelAppearance(1, self.displayState))
            }
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: UI.Dimension.Common.headerBlurViewBottomPadding,
            trailing: UI.Dimension.Common.padding
        ))
        .background(
            VisualEffectView(effect: UIBlurEffect(
                style: .systemUltraThinMaterial
            ))
            .cornerRadius(
                UI.Dimension.Common.headerBlurViewCornerRadius,
                corners: [.bottomLeft, .bottomRight]
            )
            .opacity(self.headerMaterialOpacity)
            .modifier(PanelAppearance(
                0,
                self.displayState,
                animateOffset: false
            ))
        )
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            headerView
                .zIndex(2)
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        Spacer()
                            .id(0)
                            .frame(height: UI.Dimension.Common.contentAfterTitleMarginTop)
                        HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                            NavigationLink {
                                ValidatorListView(mode: .active)
                            } label: {
                                ValidatorListButtonView(
                                    title: LocalizedStringKey("active_validator_list.title"),
                                    count: self.viewModel.networkStatus.activeValidatorCount,
                                    eraValidatorCounts: self.viewModel.eraActiveValidatorCounts,
                                    chartRevealPercentage: self.viewModel.eraActiveValidatorCounts.count > 0 ? 1.0 : 0.0,
                                    isAnimated: self.isAnimated
                                )
                            }
                            .buttonStyle(ValidatorListButtonStyle())
                            .modifier(PanelAppearance(2, self.displayState))
                            NavigationLink {
                                ValidatorListView(mode: .inactive)
                            } label: {
                                ValidatorListButtonView(
                                    title: LocalizedStringKey("inactive_validator_list.title"),
                                    count: self.viewModel.networkStatus.inactiveValidatorCount,
                                    eraValidatorCounts: self.viewModel.eraInactiveValidatorCounts,
                                    chartRevealPercentage: self.viewModel.eraInactiveValidatorCounts.count > 0 ? 1.0 : 0.0,
                                    isAnimated: self.isAnimated
                                )
                            }
                            .buttonStyle(ValidatorListButtonStyle())
                            .modifier(PanelAppearance(2, self.displayState))
                        }
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            BlockNumberView(
                                title: LocalizedStringKey("network_status.best_block_number"),
                                blockNumber: self.viewModel.networkStatus.bestBlockNumber,
                                blockWaveParameters: self.blockWaveParameters
                            )
                            .modifier(PanelAppearance(4, self.displayState))
                            BlockNumberView(
                                title: LocalizedStringKey("network_status.finalized_block_number"),
                                blockNumber: self.viewModel.networkStatus.finalizedBlockNumber
                            )
                            .modifier(PanelAppearance(5, self.displayState))
                        } else {
                            HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                BlockNumberView(
                                    title: LocalizedStringKey("network_status.best_block_number"),
                                    blockNumber: self.viewModel.networkStatus.bestBlockNumber,
                                    blockWaveParameters: self.blockWaveParameters
                                )
                                .modifier(PanelAppearance(4, self.displayState))
                                BlockNumberView(
                                    title: LocalizedStringKey("network_status.finalized_block_number"),
                                    blockNumber: self.viewModel.networkStatus.finalizedBlockNumber
                                )
                                .modifier(PanelAppearance(5, self.displayState))
                            }
                        }
                        HStack (spacing: UI.Dimension.Common.dataPanelSpacing) {
                            EraEpochView(
                                eraOrEpoch: .left(self.viewModel.networkStatus.activeEra),
                                isAnimated: self.isAnimated
                            )
                                .modifier(PanelAppearance(6, self.displayState))
                            EraEpochView(
                                eraOrEpoch: .right(self.viewModel.networkStatus.currentEpoch),
                                isAnimated: self.isAnimated
                            )
                                .modifier(PanelAppearance(7, self.displayState))
                        }
                        HStack (spacing: UI.Dimension.Common.dataPanelSpacing) {
                            EraPointsBlocksProducedView(
                                title: localized("network_status.era_points"),
                                value: self.viewModel.networkStatus.eraRewardPoints,
                                myValidatorsValue: nil
                            )
                            .modifier(PanelAppearance(8, self.displayState))
                            EraPointsBlocksProducedView(
                                title: localized("network_status.number_of_blocks"),
                                value: 0,
                                myValidatorsValue: nil
                            )
                            .modifier(PanelAppearance(9, self.displayState))
                        }
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            LastEraTotalRewardView(
                                network: self.network,
                                reward: self.viewModel.networkStatus.lastEraTotalReward
                            )
                            .modifier(PanelAppearance(10, self.displayState))
                            ValidatorBackingsView(
                                minimum: self.viewModel.networkStatus.minStake,
                                maximum: self.viewModel.networkStatus.maxStake,
                                average: self.viewModel.networkStatus.averageStake
                            )
                            .modifier(PanelAppearance(11, self.displayState))
                        } else {
                            HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                                LastEraTotalRewardView(
                                    network: self.network,
                                    reward: self.viewModel.networkStatus.lastEraTotalReward
                                )
                                .modifier(PanelAppearance(10, self.displayState))
                                ValidatorBackingsView(
                                    minimum: self.viewModel.networkStatus.minStake,
                                    maximum: self.viewModel.networkStatus.maxStake,
                                    average: self.viewModel.networkStatus.averageStake
                                )
                                .modifier(PanelAppearance(11, self.displayState))
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
                    .background(GeometryReader {
                        Color.clear
                            .preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y
                            )
                    })
                    .onPreferenceChange(ViewOffsetKey.self) {
                        self.headerMaterialOpacity = min(max($0, 0) / 40.0, 1.0)
                    }
                }
            }
            .zIndex(0)
            FooterGradientView()
                .zIndex(1)
            if self.networkSelectorIsOpen {
                NetworkSelectorView(
                    isOpen: self.$networkSelectorIsOpen,
                    serviceStatus: self.viewModel.networkStatusServiceStatus,
                    serviceIsConnected: self.networkMonitor.isConnected
                ) { network in
                    self.cancelBlockTimer()
                    self.blockWaveParameters = BlockWaveParameters(
                        offset: Angle(degrees: 0),
                        progress: 0,
                        amplitude: currentBlockWaveAmplitude
                    )
                    self.isAnimated = false
                    self.viewModel.changeNetwork(network: network)
                    self.changeNetworkDebounce?.invalidate()
                    self.changeNetworkDebounce = Timer.scheduledTimer(
                        withTimeInterval: 0.5,
                        repeats: false) { _ in
                            self.isAnimated = true
                            self.viewModel.subscribeToNetworkStatus(
                                network: self.network,
                                onStatus: self.onNetworkStatusReceived,
                                onDiff: self.onNetworkStatusDiffReceived
                            )
                        }
                }
                .zIndex(5)
            }
        }
        .navigationBarHidden(true)
        .frame(maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .onAppear() {
            self.viewModel.subscribeToNetworkStatus(
                network: self.network,
                onStatus: self.onNetworkStatusReceived,
                onDiff: self.onNetworkStatusDiffReceived
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
            }
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
                onStatus: self.onNetworkStatusReceived,
                onDiff: self.onNetworkStatusDiffReceived
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
