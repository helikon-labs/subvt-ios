//
//  ParaVoteReportViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.01.2023.
//

import Combine
import Foundation
import SubVTData

class ParaVoteReportViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    @Published private(set) var data: [(String, ParaVotesSummary)] = []
    @Published private(set) var network: Network = PreviewData.kusama
    
    private var accountId: AccountId! = nil
    private var reportService: ReportService! = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func initialize(
        networks: [Network],
        networkId: UInt64,
        accountId: AccountId
    ) {
        if let network = networks.first(where: {
            $0.id == networkId
        }) {
            self.network = network
        }
        self.accountId = accountId
        self.reportService = SubVTData.ReportService(
            host: self.network.reportServiceHost!,
            port: self.network.reportServicePort!
        )
    }
    
    var xAxisMarkCount: Int {
        return self.data.count
    }
    
    var fetchReportCount: UInt32 {
        if self.network.tokenTicker == "KSM" {
            return 30
        } else {
            return 15
        }
    }
    
    /*
    var xAxisScale: ClosedRange<Int> {
        if let first = self.data.first,
            let last = self.data.last {
            return (Int(first.session.index)...Int(last.session.index + 1))
        }
        return (0...0)
    }
     */
    
    var maxTotal: Int {
        self.data.map {
            Int($0.1.implicit + $0.1.explicit + $0.1.missed)
        }.max() ?? 0
    }
    
    func fetchReports() {
        self.fetchCurrentSession()
    }
    
    private func fetchCurrentSession() {
        guard self.fetchState != .loading else {
            return
        }
        self.fetchState = .loading
        self.reportService.getCurrentSession()
            .sink { [weak self] response in
                guard let self else { return }
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else {
                    self._fetchReports(currentSession: response.value!)
                }
            }
            .store(in: &cancellables)
    }
    
    private func _fetchReports(currentSession: Epoch) {
        guard self.fetchState == .loading else {
            return
        }
        self.fetchState = .loading
        self.reportService.getSessionValidatorReport(
            validatorAccountId: self.accountId,
            startSessionIndex: currentSession.index - self.fetchReportCount + 1,
            endSessionIndex: currentSession.index
        )
            .sink {
                [weak self] response in
                guard let self else { return }
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else {
                    self.data = response.value!.filter {
                        $0.paraVotesSummary != nil
                    }.sorted {
                        $0.session.index < $1.session.index
                    }.map {
                        (String($0.session.index), $0.paraVotesSummary!)
                    }
                    self.fetchState = .success(result: "")
                }
            }
            .store(in: &cancellables)
    }
}
