//
//  NetworkStatusViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.06.2022.
//

import Combine
import SubVTData
import SwiftUI

private let eraReportCount: UInt = 15

class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkStatus = NetworkStatus()
    @Published private(set) var networkStatusServiceStatus: RPCSubscriptionServiceStatus = .idle
    
    private var networkStatusServiceStatusSubscription: AnyCancellable? = nil
    private var networkStatusServiceSubscription: AnyCancellable? = nil
    private var networkStatusService: SubVTData.NetworkStatusService! = nil
    private var network: Network! = nil
    private var subscriptionIsInProgress = false
    
    @Published private(set) var eraActiveValidatorCounts: [(UInt, UInt)] = []
    @Published private(set) var eraInactiveValidatorCounts: [(UInt, UInt)] = []
    
    private var reportService: SubVTData.ReportService! = nil
    private var reportServiceCancellable: AnyCancellable? = nil
    
    private func initNetworkStatusService() {
        if let rpcHost = self.network?.networkStatusServiceHost,
           let rpcPort = self.network?.networkStatusServicePort {
            self.networkStatusService = SubVTData.NetworkStatusService(
                rpcHost: rpcHost,
                rpcPort: rpcPort
            )
        } else {
            self.networkStatusService = SubVTData.NetworkStatusService()
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
            subscriptionIsInProgress = false
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
        if self.networkStatusServiceStatusSubscription == nil {
            self.networkStatusServiceStatusSubscription = self.networkStatusService.$status
                .receive(on: DispatchQueue.main)
                .sink {
                    [weak self]
                    (status) in
                    self?.networkStatusServiceStatus = status
                }
        }
        self.networkStatusServiceSubscription?.cancel()
        self.networkStatusServiceSubscription = self.networkStatusService
            .subscribe()
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self]
                (completion) in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("network status finished.")
                    self.subscriptionIsInProgress = false
                case .failure(let rpcError):
                    print("network status finished with error: \(rpcError)")
                    self.subscriptionIsInProgress = false
                }
            } receiveValue: {
                [weak self]
                (event) in
                guard let self = self else { return }
                switch event {
                case .subscribed(_):
                    self.subscriptionIsInProgress = false
                    print("network status subscribed")
                case .update(let statusUpdate):
                    if let status = statusUpdate.status {
                        print("received network status \(status.bestBlockNumber)")
                        self.networkStatus = status
                        onStatus()
                    } else if let diff = statusUpdate.diff {
                        print("received network status update \(diff.bestBlockNumber ?? 0)")
                        
                        self.networkStatus.apply(diff: diff)
                        onDiff()
                    }
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    print("network status unsubscribed")
                }
            }
    }
    
    private func initReportService() {
        if let host = self.network?.reportServiceHost,
           let port = self.network?.reportServicePort {
            self.reportService = SubVTData.ReportService(
                baseURL: "https://\(host):\(port)"
            )
        } else {
            self.reportService = SubVTData.ReportService()
        }
    }
    
    func fetchEraValidatorCounts(currentEraIndex: UInt) {
        guard currentEraIndex > eraReportCount else {
            return
        }
        if self.reportService == nil {
            initReportService()
        }
        self.reportServiceCancellable = self.reportService?.getEraReport(
            startEraIndex: Int(currentEraIndex - eraReportCount),
            endEraIndex: UInt(currentEraIndex)
        ).sink {
            [weak self] response in
            guard let self = self else { return }
            // error case ignored for now
            if response.error == nil {
                let reports = response.value!
                self.eraActiveValidatorCounts = reports.map { eraReport in
                    (
                        eraReport.era.index,
                        UInt(eraReport.activeValidatorCount)
                    )
                }
                self.eraInactiveValidatorCounts = reports.map { eraReport in
                    (
                        eraReport.era.index,
                        UInt(eraReport.inactiveValidatorCount)
                    )
                }
            }
        }
    }
}
