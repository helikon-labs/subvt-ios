//
//  NetworkStatusViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.06.2022.
//

import Combine
import SubVTData
import SwiftUI
import SubVTData

private let eraReportCount: UInt32 = 15

class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkStatus = NetworkStatus()
    @Published private(set) var networkStatusServiceStatus: RPCSubscriptionServiceStatus = .idle
    
    private var networkStatusServiceStatusSubscription: AnyCancellable? = nil
    private var networkStatusServiceSubscription: AnyCancellable? = nil
    private var networkStatusService: NetworkStatusService! = nil
    private var network: Network! = nil
    private var subscriptionIsInProgress = false
    
    @Published private(set) var eraActiveValidatorCounts: [(UInt, UInt)] = []
    @Published private(set) var eraInactiveValidatorCounts: [(UInt, UInt)] = []
    
    private var reportService: ReportService! = nil
    private var reportServiceCancellable: AnyCancellable? = nil
    
    private func initNetworkStatusService() {
        if let rpcHost = self.network?.networkStatusServiceHost,
           let rpcPort = self.network?.networkStatusServicePort {
            self.networkStatusService = NetworkStatusService(
                rpcHost: rpcHost,
                rpcPort: rpcPort
            )
        } else {
            self.networkStatusService = NetworkStatusService()
        }
    }
    
    func onScenePhaseChange(
        _ scenePhase: ScenePhase,
        onStatus: @escaping () -> (),
        onDiff: @escaping () -> ()
    ) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.networkStatusService.unsubscribe()
            self.subscriptionIsInProgress = false
        case .active:
            if !subscriptionIsInProgress {
                self.subscribeToNetworkStatus(
                    network: self.network,
                    onStatus: onStatus,
                    onDiff: onDiff
                )
            }
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func changeNetwork(network: Network) {
        self.network = network
        self.networkStatusService.unsubscribe()
        self.subscriptionIsInProgress = false
        self.networkStatus = NetworkStatus()
        self.eraActiveValidatorCounts = []
        self.eraInactiveValidatorCounts = []
        self.initNetworkStatusService()
        self.initReportService()
    }
    
    func subscribeToNetworkStatus(
        network: Network,
        onStatus: @escaping () -> (),
        onDiff: @escaping () -> ()
    ) {
        switch self.networkStatusServiceStatus {
        case .subscribed(_):
            return
        default:
            break
        }
        self.subscriptionIsInProgress = true
        self.network = network
        if self.networkStatusService == nil {
            self.initNetworkStatusService()
        }
        self.networkStatusServiceStatusSubscription?.cancel()
        self.networkStatusServiceStatusSubscription = self.networkStatusService.$status
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self]
                (status) in
                self?.networkStatusServiceStatus = status
            }
        self.networkStatusServiceSubscription?.cancel()
        self.networkStatusServiceSubscription = self.networkStatusService
            .subscribe()
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self]
                (completion) in
                guard let self else { return }
                switch completion {
                case .finished:
                    log.info("Network status service subscription finished.")
                    self.subscriptionIsInProgress = false
                case .failure(let rpcError):
                    log.error("Network status service subscription finished with error: \(rpcError)")
                    self.subscriptionIsInProgress = false
                }
            } receiveValue: {
                [weak self]
                (event) in
                guard let self else { return }
                switch event {
                case .subscribed(_):
                    self.subscriptionIsInProgress = false
                    log.info("Subscribed to network status service.")
                case .update(let statusUpdate):
                    if let status = statusUpdate.status {
                        log.info("Received initial network status for block \(status.bestBlockNumber).")
                        self.networkStatus = status
                        onStatus()
                    } else if let diff = statusUpdate.diff {
                        log.info("Received network status update for block \(diff.bestBlockNumber ?? 0).")
                        self.networkStatus.apply(diff: diff)
                        onDiff()
                    }
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    log.info("Unsubscribed from network status service.")
                }
            }
    }
    
    func unsubscribe() {
        self.networkStatusService.unsubscribe()
        self.subscriptionIsInProgress = false
    }
    
    private func initReportService() {
        if let host = self.network?.reportServiceHost,
           let port = self.network?.reportServicePort {
            self.reportService = ReportService(
                host: host, port: port
            )
        } else {
            self.reportService = ReportService()
        }
    }
    
    func fetchEraValidatorCounts(currentEraIndex: UInt32) {
        guard currentEraIndex > eraReportCount else {
            return
        }
        if self.reportService == nil {
            initReportService()
        }
        self.reportServiceCancellable = self.reportService?.getEraReport(
            startEraIndex: currentEraIndex - eraReportCount,
            endEraIndex: currentEraIndex
        ).sink {
            [weak self] response in
            guard let self else { return }
            // error case ignored for now
            if response.error == nil {
                let reports = response.value!
                self.eraActiveValidatorCounts = reports.map { eraReport in
                    (
                        UInt(eraReport.era.index),
                        UInt(eraReport.activeValidatorCount)
                    )
                }
                self.eraInactiveValidatorCounts = reports.map { eraReport in
                    (
                        UInt(eraReport.era.index),
                        UInt(eraReport.inactiveValidatorCount)
                    )
                }
            }
        }
    }
}
