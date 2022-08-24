//
//  MyValidatorsViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.08.2022.
//

import Combine
import SwiftUI
import SubVTData
import SwiftEventBus

class MyValidatorsViewModel: ObservableObject {
    @Published private(set) var fetchState: DataFetchState<[ValidatorSummary]> = .idle
    private var appService = SubVTData.AppService()
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        SwiftEventBus.onMainThread(self, name: Event.validatorAdded.rawValue) { result in
            self.fetchMyValidators()
        }
        SwiftEventBus.onMainThread(self, name: Event.validatorRemoved.rawValue) { result in
            self.fetchMyValidators()
        }
    }
    
    func initReportServices(networks: [Network]) {
        guard self.reportServiceMap.count == 0 else {
            return
        }
        for network in networks {
            if let host = network.reportServiceHost,
               let port = network.reportServicePort {
                reportServiceMap[network.id] = SubVTData.ReportService(baseURL: "https://\(host):\(port)")
            }
        }
    }
    
    func fetchMyValidators() {
        self.fetchState = .loading
        self.appService.getUserValidators().sink {
            response in
            if let error = response.error {
                self.fetchState = .error(error: error)
            } else if let userValidators = response.value {
                self.fetchValidatorSummaries(userValidators: userValidators)
            }
        }
        .store(in: &cancellables)
    }
    
    private func fetchValidatorSummaries(userValidators: [UserValidator]) {
        if userValidators.isEmpty {
            self.fetchState = .success(result: [])
        }
        var publishers: [ServiceResponsePublisher<ValidatorSummaryReport>] = []
        for userValidator in userValidators {
            if let reportService = self.reportServiceMap[userValidator.networkId] {
                publishers.append(reportService.getValidatorSummaryReport(
                    validatorAccountId: userValidator.validatorAccountId
                ))
            }
        }
        Publishers.MergeMany(publishers)
            .sink { response in
                if let error = response.error {
                    self.fetchState = .error(error: error)
                } else if let validatorSummaryReport = response.value {
                    switch self.fetchState {
                    case .loading:
                        self.fetchState = .success(result: [validatorSummaryReport.validatorSummary])
                    case .success(var validatorSummaries):
                        validatorSummaries.append(validatorSummaryReport.validatorSummary)
                        self.fetchState = .success(result: validatorSummaries.sorted {
                            return $0.compare(sortOption: .identity, $1)
                        })
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }
}
