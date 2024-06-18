//
//  HomeViewController.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import Combine
import Foundation
import SubVTData
import SwiftUI

class HomeViewModel: ObservableObject {
    @AppStorage(WatchAppStorageKey.networks) private var networks: [Network]? = nil
    @Published private(set) var fetchState: DataFetchState<[Network]> = .idle
    private let service = AppService()
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchNetworks() {
        guard self.networks == nil else {
            log.info("Networks already fetched.")
            return
        }
        log.info("Fetch networks.")
        self.fetchState = .loading
        service.getNetworks()
            .sink {
                [weak self] response in
                guard let self else { return }
                if let error = response.error {
                    log.error("Error while fetching networks: \(error)")
                } else {
                    let networks = response.value!
                    log.info("\(networks.count) networks fetched successfully.")
                    self.networks = networks
                }
            }
            .store(in: &cancellables)
    }
}
