//
//  ValidatorListViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import Combine
import SubVTData
import SwiftUI

class ValidatorListViewModel: ObservableObject {
    @Published private(set) var serviceStatus: RPCSubscriptionServiceStatus = .idle
    @Published private(set) var validators: [ValidatorSummary] = []
    
    private var serviceStatusSubscription: AnyCancellable? = nil
    private var serviceSubscription: AnyCancellable? = nil
    private var service: SubVTData.ValidatorListService! = nil
    private var network: Network! = nil
    private var subscriptionIsInProgress = false
    
    private func initService() {
        if let rpcHost = self.network?.activeValidatorListServiceHost,
           let rpcPort = self.network?.activeValidatorListServicePort {
            self.service = SubVTData.ValidatorListService(
                rpcHost: rpcHost,
                rpcPort: rpcPort
            )
        } else {
            self.service = SubVTData.ValidatorListService(active: true)
        }
    }
    
    func unsubscribe() {
        self.service.unsubscribe()
        self.subscriptionIsInProgress = false
    }
    
    func onScenePhaseChange(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background:
            break
        case .inactive:
            self.service.unsubscribe()
            self.subscriptionIsInProgress = false
        case .active:
            if !self.subscriptionIsInProgress {
                self.subscribeToValidatorList(network: self.network)
            }
        @unknown default:
            fatalError("Unknown scene phase: \(scenePhase)")
        }
    }
    
    func subscribeToValidatorList(network: Network) {
        self.subscriptionIsInProgress = true
        self.network = network
        if self.service == nil {
            self.initService()
        }
        if self.serviceStatusSubscription == nil {
            self.serviceStatusSubscription = self.service.$status
                .sink {
                    [weak self]
                    (status) in
                    self?.serviceStatus = status
                }
        }
        self.serviceSubscription?.cancel()
        self.serviceSubscription = self.service
            .subscribe()
            .sink {
                [weak self]
                (completion) in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("validator list service finished.")
                    self.subscriptionIsInProgress = false
                case .failure(let rpcError):
                    print("validator list service error: \(rpcError)")
                    self.subscriptionIsInProgress = false
                }
            } receiveValue: {
                [weak self]
                (event) in
                guard let self = self else { return }
                switch event {
                case .subscribed(_):
                    self.subscriptionIsInProgress = false
                    print("validator list subscribed")
                case .update(let update):
                    print("validator list update block #\(update.finalizedBlockNumber ?? 0)")
                    print("insert \(update.insert.count) validators")
                    print("update \(update.update.count) validators")
                    print("remove \(update.removeIds.count) validators")
                    self.validators.insert(contentsOf: update.insert, at: 0)
                    // self.validators = update.insert
                case .unsubscribed:
                    self.subscriptionIsInProgress = false
                    print("validator list unsubscribed")
                case .reconnectSuggested:
                    break
                }
            }
    }
}
