//
//  NetworkStatus.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.06.2022.
//

import Combine
import SubVTData

class NetworkStatusService {
    private var cancellables: Set<AnyCancellable> = []
    private let service: SubVTData.NetworkStatusService!
    
    init(network: Network) {
        self.service = SubVTData.NetworkStatusService(
            rpcHost: network.networkStatusServiceHost!,
            rpcPort: network.networkStatusServicePort!
        )
    }
    
    func start() {
        
    }
}
