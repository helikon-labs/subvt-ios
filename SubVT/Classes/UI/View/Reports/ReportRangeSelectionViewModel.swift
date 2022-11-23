//
//  ReportRangeSelectionViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.11.2022.
//

import Combine
import Foundation
import SubVTData

class ReportRangeSelectionViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    @Published var network: Network = PreviewData.kusama
    
    private var eras: [Era] = []
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
}
