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
    @Published private(set) var fetchState: DataFetchState<String> = .idle
    
    private var userValidators: [UserValidator] = []
    @Published private(set) var userValidatorSummaries: [UserValidatorSummary] = []
    
    private var appService = SubVTData.AppService()
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    private var updateTimer: Timer? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        SwiftEventBus.onMainThread(self, name: Event.validatorAdded.rawValue) { _ in
            self.fetchMyValidators()
        }
        SwiftEventBus.onMainThread(self, name: Event.validatorRemoved.rawValue) { _ in
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
        guard self.fetchState != .loading else { return }
        self.fetchState = .loading
        self.updateTimer?.invalidate()
        self.appService.getUserValidators().sink {
            response in
            if let error = response.error {
                self.fetchState = .error(error: error)
            } else if let userValidators = response.value {
                self.userValidators = userValidators
                // remove non existent validators
                self.userValidatorSummaries.removeAll { userValidatorSummary in
                    return self.userValidators.firstIndex { userValidator in
                        return userValidator.networkId == userValidatorSummary.userValidator.networkId
                            && userValidator.validatorAccountId == userValidatorSummary.userValidator.validatorAccountId
                    } == nil
                }
                self.fetchValidatorSummaries()
            }
        }
        .store(in: &cancellables)
    }
    
    private func addOrUpdateValidatorSummary(_ validatorSummary: ValidatorSummary) {
        if let userValidator = self.userValidators.first(where: { userValidator in
            return userValidator.networkId == validatorSummary.networkId
            && userValidator.validatorAccountId == validatorSummary.accountId
        }) {
            if let index = self.userValidatorSummaries.firstIndex(where: { userValidatorSummary in
                return userValidatorSummary.userValidator.networkId == userValidator.networkId
                    && userValidatorSummary.userValidator.validatorAccountId == userValidator.validatorAccountId
            }) {
                self.userValidatorSummaries[index] = UserValidatorSummary(
                    userValidator: userValidator,
                    validatorSummary: validatorSummary
                )
            } else {
                self.userValidatorSummaries.append(UserValidatorSummary(
                    userValidator: userValidator,
                    validatorSummary: validatorSummary
                ))
            }
            self.sortUserValidatorSummaries()
        }
    }
    
    private func removeValidator(networkId: UInt64, accountId: AccountId) {
        self.userValidatorSummaries.removeAll { existing in
            return existing.userValidator.networkId == networkId
            && existing.userValidator.validatorAccountId == accountId
        }
    }
    
    private func sortUserValidatorSummaries() {
        self.userValidatorSummaries.sort {
            return $0.validatorSummary.compare(sortOption: .identity, $1.validatorSummary)
        }
    }
    
    private func fetchValidatorSummaries() {
        if self.userValidators.isEmpty {
            self.fetchState = .success(result: "")
        }
        var publishers: [ServiceResponsePublisher<ValidatorSummaryReport>] = []
        for userValidator in self.userValidators {
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
                        let validatorSummary = validatorSummaryReport.validatorSummary
                        self.addOrUpdateValidatorSummary(validatorSummary)
                        self.fetchState = .success(result: "")
                        self.setupUpdateTimer()
                    case .success:
                        self.addOrUpdateValidatorSummary(validatorSummaryReport.validatorSummary)
                        self.fetchState = .success(result: "")
                        self.setupUpdateTimer()
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func deleteUserValidator(_ toDelete: UserValidatorSummary) {
        self.removeValidator(
            networkId: toDelete.userValidator.networkId,
            accountId: toDelete.userValidator.validatorAccountId
        )
        self.appService
            .deleteUserValidator(id: toDelete.userValidator.id)
            .sink { response in
                if let _ = response.error {
                    self.addOrUpdateValidatorSummary(toDelete.validatorSummary)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(
            withTimeInterval: 10,
            repeats: true
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.fetchMyValidators()
        }
    }
}
