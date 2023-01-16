//
//  RewardReportViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.01.2023.
//

import Combine
import Foundation
import SubVTData

class RewardReportViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    @Published private(set) var data: [(Int, Balance)] = []
    
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
    
    var max: Double {
        if self.data.count > 0 {
            return Double(self.data
                .map { $0.1.value }
                .max { $0 < $1 } ?? 0) * 1.1
        }
        return 0.0
    }
    
    var xAxisMarkCount: Int {
        if let first = self.data.first,
            let last = self.data.last {
            return last.0 - first.0
        }
        return 0
    }
    
    var xAxisScale: ClosedRange<Int> {
        if let first = self.data.first,
            let last = self.data.last {
            return (first.0...(last.0 + 1))
        }
        return (0...0)
    }
    
    func fetchRewards() {
        self.fetchState = .loading
        self.reportService.getValidatorEraRewardReport(
            validatorAccountId: self.validatorSummary.accountId
        )
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else {
                    let reports = response.value!.sorted { $0.era.index < $1.era.index }
                    for report in reports {
                        let eraStartDate = Date(
                            timeIntervalSince1970: TimeInterval(report.era.startTimestamp / 1000)
                        )
                        let components = Calendar.current.dateComponents(
                            [.year, .month],
                            from: eraStartDate
                        )
                        let monthIndex = ((components.year ?? 0) * 12) + ((components.month ?? 1) - 1)
                        if let index = self.data.firstIndex(where: { $0.0 == monthIndex }) {
                            self.data[index] = (
                                monthIndex,
                                self.data[index].1 + report.reward
                            )
                        } else {
                            if let last = self.data.last {
                                for i in (last.0 + 1)..<monthIndex {
                                    self.data.append((i, Balance(integerLiteral: 0)))
                                }
                            }
                            self.data.append((
                                monthIndex,
                                report.reward
                            ))
                        }
                    }
                    self.fetchState = .success(result: "")
                }
            }
            .store(in: &cancellables)
    }
}
