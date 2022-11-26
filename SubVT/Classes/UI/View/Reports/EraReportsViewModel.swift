//
//  EraReportsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.11.2022.
//

import Combine
import Foundation
import SubVTData

class EraReportsViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    @Published private(set) var activeValidatorCounts: [(Int, Int)] = []
    @Published private(set) var inactiveValidatorCounts: [(Int, Int)] = []
    
    var network: Network! = nil
    private var reportService: ReportService! = nil
    private var cancellables = Set<AnyCancellable>()
    
    private func initReportService() {
        guard self.reportService == nil else { return }
        if let host = self.network.reportServiceHost,
           let port = self.network.reportServicePort {
            self.reportService = SubVTData.ReportService(
                host: host, port: port
            )
        }
    }
    
    func fetchReports(
        startEraIndex: UInt,
        endEraIndex: UInt
    ) {
        guard self.fetchState != .loading else { return }
        self.initReportService()
        self.fetchState = .loading
        self.reportService.getEraReport(
            startEraIndex: Int(startEraIndex),
            endEraIndex: endEraIndex
        ).sink {
            [weak self] response in
            guard let self = self else { return }
            if let error = response.error {
                self.fetchState = .error(error: error)
            } else if let reports = response.value {
                self.processReports(reports: reports)
                self.fetchState = .success(result: "")
            }
        }
        .store(in: &self.cancellables)
    }
    
    private func processReports(reports: [EraReport]) {
        self.activeValidatorCounts = reports.map {
            (Int($0.era.index), Int($0.activeValidatorCount))
        }
        self.inactiveValidatorCounts = reports.map {
            (Int($0.era.index), Int($0.inactiveValidatorCount))
        }
    }
}
