//
//  AppViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.11.2022.
//

import Combine
import Foundation
import SubVTData

class AppViewModel: ObservableObject {
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    func initReportServices(networks: [Network]) {
        guard self.reportServiceMap.count == 0 else {
            return
        }
        for network in networks {
            if let host = network.reportServiceHost,
               let port = network.reportServicePort {
                reportServiceMap[network.id] = SubVTData.ReportService(
                    host: host, port: port
                )
            }
        }
    }
    
    func fetchOneKVNominatorsForNetwork(_ network: Network, onSuccess: @escaping ([String]) -> ()) {
        var result: [String] = []
        let reportService = reportServiceMap[network.id]
        reportService?.getOneKVNominatorSummaries()
            .sink {
                response in
                if let _ = response.error {
                    // no-op
                } else if let nominators = response.value {
                    for nominator in nominators {
                        result.append(nominator.stashAddress)
                    }
                    onSuccess(result)
                }
            }
            .store(in: &cancellables)
    }
}
