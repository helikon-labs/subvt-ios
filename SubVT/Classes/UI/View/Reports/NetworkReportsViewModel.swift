//
//  NetworkReportsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 24.11.2022.
//

import BigInt
import Combine
import Foundation
import SubVTData

class NetworkReportsViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    
    @Published private(set) var activeNominatorCounts: [(Int, Int)] = []
    
    @Published private(set) var totalStakes: [(Int, Double)] = []
    @Published private(set) var totalStakesBalance: [(Int, Balance)] = []
    
    @Published private(set) var activeValidatorCounts: [(Int, Int)] = []
    @Published private(set) var inactiveValidatorCounts: [(Int, Int)] = []
    @Published private(set) var rewardPoints: [(Int, Double)] = []
    @Published private(set) var totalPaidOut: [(Int, Double)] = []
    @Published private(set) var totalPaidOutBalance: [(Int, Balance)] = []
    
    @Published private(set) var totalRewards: [(Int, Double)] = []
    @Published private(set) var totalRewardsBalance: [(Int, Balance)] = []
    @Published private(set) var offlineOffenceCounts: [(Int, Double)] = []
    @Published private(set) var slashes: [(Int, Double)] = []
    @Published private(set) var slashesBalance: [(Int, Balance)] = []
    
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
        self.activeNominatorCounts = reports.map {
            (Int($0.era.index), Int($0.activeNominatorCount ?? 0))
        }
        self.activeValidatorCounts = reports.map {
            (Int($0.era.index), Int($0.activeValidatorCount))
        }
        self.inactiveValidatorCounts = reports.map {
            (Int($0.era.index), Int($0.inactiveValidatorCount))
        }
        self.rewardPoints = reports.map {
            (Int($0.era.index), Double($0.totalRewardPoints ?? 0))
        }
        self.totalPaidOut = reports.map {
            (
                (Int($0.era.index)),
                Double($0.totalPaidOut.value) / Double(self.network.tokenDecimalCount)
            )
        }
        self.totalPaidOutBalance = reports.map {
            (
                (Int($0.era.index)),
                $0.totalPaidOut
            )
        }
        self.totalStakes = reports.map {
            (
                (Int($0.era.index)),
                Double($0.totalStake?.value ?? 0) / Double(self.network.tokenDecimalCount)
            )
        }
        self.totalStakesBalance = reports.map {
            (
                (Int($0.era.index)),
                $0.totalStake ?? Balance(value: 0)
            )
        }
        self.totalRewards = reports.map {
            (
                (Int($0.era.index)),
                Double($0.totalReward?.value ?? 0) / Double(self.network.tokenDecimalCount)
            )
        }
        self.totalRewardsBalance = reports.map {
            (
                (Int($0.era.index)),
                $0.totalReward ?? Balance(value: 0)
            )
        }
        self.offlineOffenceCounts = reports.map {
            (Int($0.era.index), Double($0.offlineOffenceCount))
        }
        self.slashes = reports.map {
            (
                (Int($0.era.index)),
                Double($0.slashedAmount.value) / Double(self.network.tokenDecimalCount)
            )
        }
        self.slashesBalance = reports.map {
            (
                (Int($0.era.index)),
                $0.slashedAmount
            )
        }
    }
    
    var maxActiveNominatorCount: Int {
        self.activeNominatorCounts.map{ $0.1 }.max { $0 < $1 } ?? 0
    }
    
    var maxActiveValidatorCount: Int {
        self.activeValidatorCounts.map{ $0.1 }.max { $0 < $1 } ?? 0
    }
    
    var maxRewardPoint: Double {
        let max = self.rewardPoints.map{ Double($0.1) }.max { $0 < $1 } ?? 0
        return Double(max)
    }
    
    var maxTotalPaidOut: Double {
        return self.totalPaidOut.map{ $0.1 }.max { $0 < $1 } ?? 0
    }
    
    var maxTotalStake: Double {
        return  self.totalStakes.map{ $0.1 }.max { $0 < $1 } ?? 0
    }
    
    var maxTotalReward: Double {
        return self.totalRewards.map{ $0.1 }.max { $0 < $1 } ?? 0
    }
    
    var maxOfflineOffenceCount: Double {
        let max = self.offlineOffenceCounts.map{ Double($0.1) }.max { $0 < $1 } ?? 0.0
        guard max > 0.0 else {
            return 1.0
        }
        return max
    }
    
    var maxSlash: Double {
        let max = self.slashes.map{ $0.1 }.max { $0 < $1 } ?? 0
        guard max > 0 else {
            return 1.0
        }
        return max
    }
}
