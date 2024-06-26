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
    @AppStorage(WatchAppStorageKey.networks) var networks: [Network]? = nil
    @AppStorage(WatchAppStorageKey.selectedNetwork) var network: Network = PreviewData.kusama
    private var networkStatusTimer: Timer? = nil
    
    @Published private(set) var eraActiveValidatorCounts: [(UInt, UInt)] = []
    @Published private(set) var eraInactiveValidatorCounts: [(UInt, UInt)] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var reportService: ReportService! = nil
    
    func onScenePhaseChange(
        _ scenePhase: ScenePhase,
        onInit: @escaping () -> (),
        onUpdate: @escaping () -> ()
    ) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.unsubscribe()
        case .active:
            self.subscribeToNetworkStatus(onInit: onInit, onUpdate: onUpdate)
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func changeNetwork(network: Network) {
        self.network = network
        self.unsubscribe()
        self.networkStatus = NetworkStatus()
        self.eraActiveValidatorCounts = []
        self.eraInactiveValidatorCounts = []
        self.reportService = nil
        self.initReportService()
    }
    
    func fetchNetworkStatus(
        onInit: @escaping () -> (),
        onUpdate: @escaping () -> ()
    ) {
        self.reportService.getNetworkStatus().sink {
            [weak self]
            response in
            guard let self else { return }
            if let error = response.error {
                DispatchQueue.main.async {
                    self.networkStatusServiceStatus = .error(error: RPCError.backend(error: error))
                }
            } else if let networkStatus = response.value {
                let oldBestBlockNumber = self.networkStatus.bestBlockNumber
                let newBestBlockNumber = networkStatus.bestBlockNumber
                self.networkStatus = networkStatus
                if newBestBlockNumber > oldBestBlockNumber {
                    if oldBestBlockNumber == 0 {
                        onInit()
                    } else {
                        onUpdate()
                    }
                }
                DispatchQueue.main.async {
                    self.networkStatusServiceStatus = .subscribed(subscriptionId: 0)
                }
            } else {
                DispatchQueue.main.async {
                    self.networkStatusServiceStatus = .error(error: RPCError.connection)
                }
            }
            self.networkStatusTimer = Timer.scheduledTimer(
                withTimeInterval: 1.5,
                repeats: false
            ) {
                [weak self] _ in
                guard let self else { return }
                self.fetchNetworkStatus(onInit: onInit, onUpdate: onUpdate)
            }
        }
        .store(in: &cancellables)
    }
    
    func subscribeToNetworkStatus(
        onInit: @escaping () -> (),
        onUpdate: @escaping () -> ()
    ) {
        switch self.networkStatusServiceStatus {
        case .subscribed(_):
            return
        default:
            break
        }
        self.unsubscribe()
        self.initReportService()
        self.fetchNetworkStatus(onInit: onInit, onUpdate: onUpdate)
        DispatchQueue.main.async {
            self.networkStatusServiceStatus = .subscribed(subscriptionId: 0)
        }
    }
    
    func unsubscribe() {
        self.networkStatusTimer?.invalidate()
        self.networkStatusTimer = nil
        DispatchQueue.main.async {
            self.networkStatusServiceStatus = .idle
        }
    }
    
    private func initReportService() {
        guard self.reportService == nil else {
            return
        }
        if let host = self.network.reportServiceHost,
           let port = self.network.reportServicePort {
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
        self.reportService?.getEraReport(
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
        .store(in: &cancellables)
    }
}
