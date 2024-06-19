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
    @AppStorage(WatchAppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
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
                        isConnected: self.networkMonitor.isConnected,
                        size: UI.Dimension.Common.connectionStatusSize
                    )
                    //.modifier(PanelAppearance(5, self.displayState))
                }
                .modifier(PanelAppearance(0, self.displayState))
                Spacer()
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
        VStack(alignment: .leading) {
            headerView
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
                }
                .padding(EdgeInsets(
                    top: 0,
                    leading: UI.Dimension.Common.padding,
                    bottom: 0,
                    trailing: UI.Dimension.Common.padding
                ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear() {
            self.viewModel.subscribeToNetworkStatus(
                network: network,
                onStatus: self.onNetworkStatusReceived,
                onDiff: self.onNetworkStatusDiffReceived
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
