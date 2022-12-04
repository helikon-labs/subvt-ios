//
//  ValidatorReportsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.12.2022.
//

import Combine
import Foundation
import SubVTData

class ValidatorReportsViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    
    private var validatorSummary: ValidatorSummary! = nil
    private var network: Network! = nil
    private var reportService: ReportService! = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func initialize(
        validatorSummary: ValidatorSummary,
        network: Network
    ) {
        self.validatorSummary = validatorSummary
        self.network = network
        self.reportService = SubVTData.ReportService(
            host: self.network.reportServiceHost!,
            port: self.network.reportServicePort!
        )
    }
    
    func fetchReports(
        startEraIndex: UInt,
        endEraIndex: UInt
    ) {
        guard self.fetchState != .loading else { return }
        self.fetchState = .loading
        self.reportService.getEraValidatorReport(
            validatorAccountId: self.validatorSummary.accountId,
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
    
    private func processReports(reports: [EraValidatorReport]) {
        
    }
}
