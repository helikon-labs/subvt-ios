//
//  NetworkStatusViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.06.2022.
//

import Combine
import SubVTData
import SwiftUI

class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var network: Network
    @Published private(set) var networkStatus = NetworkStatus()
    @Published private(set) var networkStatusServiceStatus: RPCSubscriptionServiceStatus = .idle
    
    private var networkStatusServiceStatusSubscription: AnyCancellable? = nil
    private var networkStatusServiceSubscription: AnyCancellable? = nil
    private let networkStatusService: SubVTData.NetworkStatusService
    
    private var subscriptionIsInProgress = false
    
    init() {
        guard let network = Settings.getSelectedNetwork() else {
            fatalError("Network not selected before network status screen.")
        }
        self.network = network
        if let host = network.networkStatusServiceHost,
           let port = network.networkStatusServicePort {
            self.networkStatusService = NetworkStatusService(
                rpcHost: host,
                rpcPort: port
            )
        } else {
            self.networkStatusService = NetworkStatusService()
        }
    }
    
    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.networkStatusService.unsubscribe()
            subscriptionIsInProgress = false
        case .active:
            if !subscriptionIsInProgress {
                self.subscribeToNetworkStatus()
            }
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func subscribeToNetworkStatus() {
        self.subscriptionIsInProgress = true
        if self.networkStatusServiceStatusSubscription == nil {
            self.networkStatusServiceStatusSubscription = self.networkStatusService.$status
                .sink {
                    [weak self]
                    (status) in
                    self?.networkStatusServiceStatus = status
                }
        }
        self.networkStatusServiceSubscription?.cancel()
        self.networkStatusServiceSubscription = self.networkStatusService
            .subscribe()
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
                    } else if let diff = statusUpdate.diff {
                        print("received network status update \(diff.bestBlockNumber ?? 0)")
                        self.networkStatus.apply(diff: diff)
                    }
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    print("network status unsubscribed")
                case .reconnectSuggested:
                    break
                }
            }
    }
}
