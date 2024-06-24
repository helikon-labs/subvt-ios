//
//  IncomeViewModel.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 18.06.2024.
//

import Combine
import Foundation
import SubVTData
import SwiftUI

class IncomeViewModel: ObservableObject {
    @AppStorage(WatchAppStorageKey.networks) private(set) var networks: [Network]? = nil
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    
    @Published private(set) var userValidators: [UserValidator] = []
    @Published private(set) var monthlyIncome: [MonthlyIncome] = []
    @Published private(set) var maxMonthlyIncome: Decimal = 0
    private var monthlyIncomeReportMap: [AccountId:MonthlyIncomeReport] = [:]
    
    private var appService = SubVTData.AppService()
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    func initReportServices() {
        guard self.reportServiceMap.count == 0,
              let networks = self.networks else {
            return
        }
        self.networks = networks
        for network in networks {
            if let host = network.reportServiceHost,
               let port = network.reportServicePort {
                reportServiceMap[network.id] = SubVTData.ReportService(
                    host: host, port: port
                )
            }
        }
    }
    
    func fetchMyValidators() {
        guard self.fetchState != .loading else { return }
        self.fetchState = .loading
        self.userValidators = []
        self.appService.getUserValidators().sink {
            [weak self]
            response in
            guard let self else { return }
            if let error = response.error {
                self.fetchState = .error(error: error)
            } else if let userValidators = response.value {
                self.userValidators = userValidators
                if self.userValidators.isEmpty {
                    self.fetchState = .success(result: "")
                } else {
                    self.fetchMonthlyIncomes()
                }
            }
        }
        .store(in: &cancellables)
    }
    
    private func fetchMonthlyIncomes() {
        self.initReportServices()
        self.monthlyIncomeReportMap = [:]
        self.monthlyIncome = []
        var publishers: [ServiceResponsePublisher<MonthlyIncomeReport>] = []
        for userValidator in self.userValidators {
            if let reportService = self.reportServiceMap[userValidator.networkId] {
                publishers.append(reportService.getMonthlyIncomeReport(
                    rewardeeAccountId: userValidator.validatorAccountId
                ))
            }
        }
        Publishers.MergeMany(publishers)
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else if let monthlyIncomeReport = response.value {
                    switch self.fetchState {
                    case .loading:
                        self.monthlyIncomeReportMap[monthlyIncomeReport.rewardee] = monthlyIncomeReport
                        if self.monthlyIncomeReportMap.count == self.userValidators.count {
                            self.processMonthlyIncomes()
                            self.fetchState = .success(result: "")
                        }
                    default:
                        break
                    }
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func processMonthlyIncomes() {
        var monthlyIncome: [MonthlyIncome] = []
        for monthlyIncomeReport in self.monthlyIncomeReportMap.values {
            for monthlyIncomeInstance in monthlyIncomeReport.monthlyIncome {
                if let i = monthlyIncome.firstIndex(where: { monthlyIncome in
                    monthlyIncome.month == monthlyIncomeInstance.month
                        && monthlyIncome.year == monthlyIncomeInstance.year
                }) {
                    monthlyIncome[i] = MonthlyIncome(
                        year: monthlyIncomeInstance.year,
                        month: monthlyIncomeInstance.month,
                        income: monthlyIncome[i].income + monthlyIncomeInstance.income
                    )
                } else {
                    monthlyIncome.append(monthlyIncomeInstance)
                }
            }
        }
        self.monthlyIncome = monthlyIncome.sorted(by: { m1, m2 in
            if m1.year > m2.year {
                return true
            } else if m1.year < m2.year {
                return false
            } else if m1.month > m2.month {
                return true
            }
            return false
        })
        self.maxMonthlyIncome = self.monthlyIncome.max(by: { m1, m2 in
            m1.income < m2.income
        })?.income ?? Decimal.greatestFiniteMagnitude
    }
}
