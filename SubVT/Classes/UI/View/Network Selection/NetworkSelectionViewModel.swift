//
//  NetworkSelectionViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.06.2022.
//

import Combine
import SwiftUI
import SubVTData

class NetworkSelectionViewModel: ObservableObject {
    enum FetchState: Hashable {
        case idle
        case loading
        case error(error: APIError)
        case success(networks: [Network])
    }
    
    @Published var fetchState: FetchState = .idle
    private let service = AppService()
    private var cancellables: Set<AnyCancellable> = []
    private var fetchTimer: Timer? = nil
    private var networks: [Network]! = nil
    
    func fetchNetworks(
        storedNetworks: [Network]?,
        onSuccess: @escaping ([Network]) -> ()
    ) {
        if let networks = storedNetworks {
            self.fetchState = .success(networks: networks)
            return
        }
        self.fetchState = .loading
        self.fetchTimer = Timer.scheduledTimer(
            withTimeInterval: 1.5,
            repeats: false
        ) {
            [weak self] _ in
            guard let self = self else { return }
            if self.networks != nil {
                self.fetchState = .success(networks: self.networks)
                onSuccess(self.networks)
            }
        }
        service.getNetworks()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.fetchState = .error(error: error)
                    self.fetchTimer?.invalidate()
                } else {
                    if self.fetchTimer?.isValid ?? false {
                        self.networks = response.value!
                    } else {
                        self.fetchState = .success(networks: response.value!)
                        onSuccess(response.value!)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
