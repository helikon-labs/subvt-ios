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
    enum FetchState {
        case idle
        case loading
        case error(error: APIError)
        case success(networks: [Network])
    }
    
    @Published var fetchState: FetchState = .idle
    private let service = AppService()
    private var cancellables: Set<AnyCancellable> = []
    
    func getNetworks() {
        self.fetchState = .loading
        service.getNetworks()
            .sink { response in
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else {
                    self.fetchState = .success(networks: response.value!)
                }
            }
            .store(in: &cancellables)
    }
}
