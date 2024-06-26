//
//  NetworkStatus.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import Combine
import Foundation
import SwiftUI
import SubVTData

fileprivate var avgBlockTimeSec = 6.0
fileprivate var blockTimerStartTimeSec = 0.0
fileprivate let blockTimerPeriodSec = 0.01
fileprivate let blockWaveAmplitudeRange = 0.05...0.1
fileprivate var blockWaveMaxOffsetDegrees = -1440.0
fileprivate var currentBlockWaveAmplitude = blockWaveAmplitudeRange.lowerBound

struct NetworkStatusView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = NetworkStatusViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var displayState: BasicViewDisplayState = .notAppeared
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
    
    func onNetworkStatusInitialized() {
        self.startBlockTimer()
        self.viewModel.fetchEraValidatorCounts(
            currentEraIndex: self.viewModel.networkStatus.activeEra.index
        )
    }
    
    func onNetworkStatusUpdated() {
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
            HStack(alignment: .center) {
                HStack(alignment: .top, spacing: 0) {
                    Text(localized("network_status.title"))
                        .font(UI.Font.Common.title)
                        .foregroundColor(Color("Text"))
                    Spacer()
                        .frame(
                            width: UI.Dimension.NetworkStatus.connectionStatusMarginLeft
                        )
                    WSRPCStatusIndicatorView(
                        status: self.viewModel.networkStatusServiceStatus,
                        size: UI.Dimension.Common.connectionStatusSize
                    )
                }
                Spacer()
                Button(action: {
                    self.networkSelectorIsOpen = true
                }, label: {
                    UI.Image.Common.networkIcon(
                        network: self.viewModel.network
                    )
                    .resizable()
                    .frame(
                        width: UI.Dimension.NetworkStatus.networkIconSize,
                        height: UI.Dimension.NetworkStatus.networkIconSize
                    )
                    .padding(1.0)
                    .overlay(
                            RoundedRectangle(cornerRadius: UI.Dimension.NetworkStatus.networkIconSize)
                                .stroke(Color("Text"), lineWidth: 1)
                                .opacity(0.5)
                        )
                })
                .buttonStyle(PushButtonStyle())
                /*
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
                 */
            }
        }
        .padding(EdgeInsets(
            top: 0,
            leading: UI.Dimension.Common.padding,
            bottom: 0,
            trailing: UI.Dimension.Common.padding
        ))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                headerView
                    .modifier(PanelAppearance(0, self.displayState))
                ScrollView {
                    VStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                        HStack(spacing: UI.Dimension.Common.dataPanelSpacing) {
                            ValidatorListButtonView(
                                title: LocalizedStringKey("active_validator_list.title"),
                                count: self.viewModel.networkStatus.activeValidatorCount,
                                eraValidatorCounts: self.viewModel.eraActiveValidatorCounts,
                                chartRevealPercentage: self.viewModel.eraActiveValidatorCounts.count > 0 ? 1.0 : 0.0,
                                isAnimated: self.isAnimated
                            )
                            .modifier(PanelAppearance(1, self.displayState))
                            ValidatorListButtonView(
                                title: LocalizedStringKey("inactive_validator_list.title"),
                                count: self.viewModel.networkStatus.inactiveValidatorCount,
                                eraValidatorCounts: self.viewModel.eraInactiveValidatorCounts,
                                chartRevealPercentage: self.viewModel.eraInactiveValidatorCounts.count > 0 ? 1.0 : 0.0,
                                isAnimated: self.isAnimated
                            )
                            .modifier(PanelAppearance(2, self.displayState))
                        }
                        BlockNumberView(
                            title: LocalizedStringKey("network_status.best_block_number"),
                            blockNumber: self.viewModel.networkStatus.bestBlockNumber,
                            blockWaveParameters: self.blockWaveParameters
                        )
                        .modifier(PanelAppearance(3, self.displayState))
                        BlockNumberView(
                            title: LocalizedStringKey("network_status.finalized_block_number"),
                            blockNumber: self.viewModel.networkStatus.finalizedBlockNumber
                        )
                        .modifier(PanelAppearance(4, self.displayState))
                        EraEpochView(
                            eraOrEpoch: .left(self.viewModel.networkStatus.activeEra),
                            isAnimated: self.isAnimated
                        )
                        .modifier(PanelAppearance(5, self.displayState))
                        EraEpochView(
                            eraOrEpoch: .right(self.viewModel.networkStatus.currentEpoch),
                            isAnimated: self.isAnimated
                        )
                        .modifier(PanelAppearance(6, self.displayState))
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                }
            }
            if self.networkSelectorIsOpen {
                if let networks = self.viewModel.networks {
                    VStack(alignment: .center) {
                        HStack {
                            ForEach(networks.indices, id: \.self) { i in
                                Button(
                                    action: {
                                        if networks[i].id != self.viewModel.network.id {
                                            self.cancelBlockTimer()
                                            self.blockWaveParameters = BlockWaveParameters(
                                                offset: Angle(degrees: 0),
                                                progress: 0,
                                                amplitude: currentBlockWaveAmplitude
                                            )
                                            self.isAnimated = false
                                            self.viewModel.changeNetwork(network: networks[i])
                                            self.changeNetworkDebounce?.invalidate()
                                            self.changeNetworkDebounce = Timer.scheduledTimer(
                                                withTimeInterval: 0.25,
                                                repeats: false
                                            ) { _ in
                                                self.isAnimated = true
                                                self.networkSelectorIsOpen = false
                                                self.viewModel.subscribeToNetworkStatus(
                                                    onInit: self.onNetworkStatusInitialized,
                                                    onUpdate: self.onNetworkStatusUpdated
                                                )
                                            }
                                            /*
                                            
                                            
                                             */
                                        }
                                    },
                                    label: {
                                        NetworkButtonView(
                                            isSelected: self.viewModel.network.id == networks[i].id,
                                            network: networks[i]
                                        )
                                    }
                                )
                                .zIndex(100 - Double(i))
                                .buttonStyle(NetworkButtonStyle())
                            }
                        }
                    }
                    .padding(EdgeInsets(
                        top: 0,
                        leading: UI.Dimension.Common.padding,
                        bottom: 0,
                        trailing: UI.Dimension.Common.padding
                    ))
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                    .background(Color("Bg").opacity(0.975))
                    .onTapGesture {
                        self.networkSelectorIsOpen = false
                    }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .onAppear() {
            self.viewModel.subscribeToNetworkStatus(
                onInit: self.onNetworkStatusInitialized,
                onUpdate: self.onNetworkStatusUpdated
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.displayState = .appeared
            }
        }
        .onDisappear() {
            self.viewModel.unsubscribe()
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
                onInit: self.onNetworkStatusInitialized,
                onUpdate: self.onNetworkStatusUpdated
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
