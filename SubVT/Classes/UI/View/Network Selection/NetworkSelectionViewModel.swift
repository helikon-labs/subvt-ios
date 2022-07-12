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
    @Published private(set) var fetchState: DataFetchState<[Network]> = .idle
    private let service = AppService()
    private var cancellables: Set<AnyCancellable> = []
    private var fetchTimer: Timer? = nil
    private var result: Either<[Network], APIError>? = nil
    
    func fetchNetworks(
        storedNetworks: [Network]?,
        onSuccess: @escaping ([Network]) -> ()
    ) {
        if let networks = storedNetworks {
            self.fetchState = .success(result: networks)
            return
        }
        self.fetchState = .loading
        self.result = nil
        self.fetchTimer = Timer.scheduledTimer(
            withTimeInterval: 0.75,
            repeats: false
        ) {
            [weak self] _ in
            guard let self = self else { return }
            if let result = self.result {
                switch result {
                case .left(let networks):
                    self.fetchState = .success(result: networks)
                    onSuccess(networks)
                case .right(let error):
                    self.fetchState = .error(error: error)
                }
            }
        }
        service.getNetworks()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    if self.fetchTimer?.isValid ?? false {
                        self.result = .right(error)
                    } else {
                        self.fetchState = .error(error: error)
                        self.fetchTimer?.invalidate()
                    }
                } else {
                    if self.fetchTimer?.isValid ?? false {
                        self.result = .left(response.value!)
                    } else {
                        self.fetchState = .success(result: response.value!)
                        onSuccess(response.value!)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
