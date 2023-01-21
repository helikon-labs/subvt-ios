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
    
    @Published private(set) var isActive: [(Int, Int)] = []
    @Published private(set) var commissionPerTenThousand: [(Int, Int)] = []
    @Published private(set) var selfStake: [(Int, Balance)] = []
    @Published private(set) var totalStake: [(Int, Balance)] = []
    @Published private(set) var blockCount: [(Int, Int)] = []
    @Published private(set) var rewardPoints: [(Int, Int)] = []
    @Published private(set) var selfReward: [(Int, Balance)] = []
    @Published private(set) var stakerReward: [(Int, Balance)] = []
    @Published private(set) var offlineOffences: [(Int, Int)] = []
    @Published private(set) var chillings: [(Int, Int)] = []
    @Published private(set) var slashes: [(Int, Balance)] = []
    
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
        startEraIndex: UInt32,
        endEraIndex: UInt32
    ) {
        guard self.fetchState != .loading else { return }
        self.fetchState = .loading
        self.reportService.getEraValidatorReport(
            validatorAccountId: self.validatorSummary.accountId,
            startEraIndex: startEraIndex,
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
        self.isActive = reports.map {
            (Int($0.era.index), ($0.isActive ?? false) ? 1 : 0)
        }
        self.commissionPerTenThousand = reports.map {
            (Int($0.era.index), Int(($0.commissionPerBillion ?? 0) / 100000))
        }
        self.selfStake = reports.map {
            (Int($0.era.index), $0.selfStake ?? Balance(integerLiteral: 0))
        }
        self.totalStake = reports.map {
            (Int($0.era.index), $0.totalStake ?? Balance(integerLiteral: 0))
        }
        self.blockCount = reports.map {
            (Int($0.era.index), Int($0.blockCount))
        }
        self.rewardPoints = reports.map {
            (Int($0.era.index), Int($0.rewardPoints ?? 0))
        }
        self.selfReward = reports.map {
            (Int($0.era.index), $0.selfReward)
        }
        self.stakerReward = reports.map {
            (Int($0.era.index), $0.stakerReward)
        }
        self.offlineOffences = reports.map {
            (Int($0.era.index), Int($0.offlineOffenceCount))
        }
        self.chillings = reports.map {
            (Int($0.era.index), Int($0.chillingCount))
        }
        self.slashes = reports.map {
            (Int($0.era.index), $0.slashedAmount)
        }
    }
    
    var maxSelfStake: Double {
        return self.selfStake.map { Double($0.1.value) }.max { $0 < $1 } ?? 0
    }
    
    var maxTotalStake: Double {
        return self.totalStake.map { Double($0.1.value) }.max { $0 < $1 } ?? 0
    }
    
    var maxBlockCount: Int {
        return max(
            self.blockCount.map { $0.1 }.max { $0 < $1 } ?? 0,
            1
        )
    }
    
    var maxRewardPoints: Int {
        return max(
            self.rewardPoints.map { $0.1 }.max { $0 < $1 } ?? 0,
            1
        )
    }
    
    var maxSelfReward: Double {
        return self.selfReward.map { Double($0.1.value) }.max { $0 < $1 } ?? 0
    }
    
    var maxStakerReward: Double {
        return self.stakerReward.map { Double($0.1.value) }.max { $0 < $1 } ?? 0
    }
    
    var maxOfflineOffence: Double {
        return self.offlineOffences.map { Double($0.1) }.max { $0 < $1 } ?? 0
    }
    
    var maxChillingCount: Double {
        return self.offlineOffences.map { Double($0.1) }.max { $0 < $1 } ?? 0
    }
    
    var maxSlash: Double {
        return self.slashes.map { Double($0.1.value) }.max { $0 < $1 } ?? 0
    }
}
