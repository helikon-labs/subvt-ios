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
    @Published private(set) var startEra: Era? = nil
    @Published private(set) var endEra: Era? = nil
    
    private(set) var eras: [Era] = []
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private let maxEraRange: UInt = 20
    
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
    
    func fetchEras() {
        guard self.fetchState != .loading,
              let service = self.reportServiceMap[self.network.id] else {
            return
        }
        self.fetchState = .loading
        self.startEra = nil
        self.endEra = nil
        service.getAllEras().sink {
            [weak self]
            response in
            guard let self = self else { return }
            if let error = response.error {
                self.fetchState = .error(error: error)
            } else if let eras = response.value {
                self.eras = eras.sorted {
                    $0.index > $1.index
                }
                self.fetchState = .success(result: "")
                if self.eras.count > 0 {
                    self.endEra = self.eras.first
                    self.startEra = self.eras[Int(min(self.maxEraRange - 1, UInt(self.eras.count - 1)))]
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func setStartEra(_ startEra: Era) {
        self.startEra = startEra
        guard let endEra = self.endEra else { return }
        if startEra.index > endEra.index {
            self.endEra = startEra
        } else if (endEra.index - startEra.index + 1) > maxEraRange {
            self.endEra = self.eras.first(where: {
                $0.index == startEra.index + maxEraRange - 1
            })
        }
    }
    
    func setEndEra(_ endEra: Era) {
        self.endEra = endEra
        guard let startEra = self.startEra else { return }
        if endEra.index < startEra.index  {
            self.startEra = endEra
        } else if (endEra.index - startEra.index + 1) > maxEraRange {
            self.startEra = self.eras.first(where: {
                $0.index == endEra.index - maxEraRange + 1
            })
        }
    }
}
