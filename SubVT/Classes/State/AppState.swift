//
//  AppViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 17.06.2022.
//
import Combine
import SubVTData
import SwiftUI

class AppState: ObservableObject {
    @Published var stage: Stage = .introduction
    @Published private(set) var network: Network!
    @Published private(set) var networkStatus = NetworkStatus()
    @Published private(set) var networkStatusServiceStatus: RPCSubscriptionServiceStatus = .idle
    
    private var networkStatusServiceStatusSubscription: AnyCancellable? = nil
    private var networkStatusServiceSubscription: AnyCancellable? = nil
    private var networkStatusService: SubVTData.NetworkStatusService? = nil
    
    init() {
        if let network = Settings.getSelectedNetwork() {
            self.stage = .home
            self.setNetwork(network)
        } else if Settings.hasOnboarded {
            self.stage = .networkSelection
        } else {
            self.stage = .introduction
        }
    }
    
    func setNetwork(_ network: Network, subscribe: Bool = false) {
        self.network = network
        if subscribe {
            self.subscribeToNetworkStatus()
        }
    }
    
    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.networkStatusService?.unsubscribe()
        case .active:
            subscribeToNetworkStatus()
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    private func initNetworkStatusService() {
        guard let network = self.network,
              self.networkStatusService == nil else {
            return
        }
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
    
    private func subscribeToNetworkStatus() {
        initNetworkStatusService()
        guard let networkStatusService = self.networkStatusService else {
            return
        }
        self.networkStatusServiceStatusSubscription = networkStatusService.$status
            .sink {
                [weak self]
                (status) in
                self?.networkStatusServiceStatus = status
            }
        networkStatusServiceSubscription = networkStatusService
            .subscribe()
            .sink { (completion) in
                switch completion {
                case .finished:
                    print("network status finished.")
                case .failure(let rpcError):
                    print("network status finished with error: \(rpcError)")
                }
            } receiveValue: {
                [weak self]
                (event) in
                switch event {
                case .update(let statusUpdate):
                    if let status = statusUpdate.status {
                        print("received network status \(status.bestBlockNumber)")
                        self?.networkStatus = status
                    } else if let diff = statusUpdate.diff {
                        print("received network status update \(diff.bestBlockNumber ?? 0)")
                        self?.networkStatus.apply(diff: diff)
                    }
                case .unsubscribed:
                    print("network status unsubscribed")
                default:
                    break
                }
            }
    }
}
