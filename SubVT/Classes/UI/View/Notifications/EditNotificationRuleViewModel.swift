//
//  EditNotificationRuleViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.10.2022.
//

import Combine
import Foundation
import SubVTData

class EditNotificationRuleViewModel: ObservableObject {
    @Published private(set) var dataFetchState: DataFetchState<String> = .idle
    @Published private(set) var dataPersistState: DataFetchState<String> = .idle
    @Published private(set) var notificationTypes: [NotificationType] = []
    @Published private(set) var filteredUserValidatorSummaries: [UserValidatorSummary] = []
    @Published private(set) var userNotificationRules: [UserNotificationRule] = []
    @Published var network: Network? = nil
    @Published var notificationType: NotificationType! = nil
    @Published var validator: UserValidatorSummary? = nil
    @Published var periodType: NotificationPeriodType = .immediate
    @Published var period: UInt16 = 0
    @Published var availablePeriods: [UInt16] = [0]
    
    private var userValidators: [UserValidator] = []
    private var userValidatorSummaries: [UserValidatorSummary] = []
    private var appService = SubVTData.AppService()
    private var cancellables: Set<AnyCancellable> = []
    private var reportServiceMap: [UInt64:SubVTData.ReportService] = [:]
    
    init() {
        self.$network.sink { newNetwork in
            self.filterNetworkValidators(network: newNetwork)
        }
        .store(in: &self.cancellables)
        self.$periodType.sink { newPeriodType in
            switch newPeriodType {
            case .off, .immediate:
                self.period = 0
                self.availablePeriods = [0]
            case .hour:
                self.period = 1
                self.availablePeriods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
            case .day:
                self.period = 1
                self.availablePeriods = [1, 2, 3, 4]
            case .epoch:
                self.period = 1
                self.availablePeriods = [1, 2, 3, 4]
            case .era:
                self.period = 1
                self.availablePeriods = [1, 2]
            }
        }
        .store(in: &self.cancellables)
    }
    
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
    
    func resetDataPersistState() {
        self.dataPersistState = .idle
    }
    
    func fetchData() {
        self.dataFetchState = .loading
        self.fetchNotificationTypes()
    }
    
    private func fetchNotificationTypes() {
        self.appService.getNotificationTypes()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.dataFetchState = .error(error: error)
                } else if let notificationTypes = response.value {
                    self.notificationTypes = notificationTypes.filter({ notificationType in
                        notificationType.isEnabled
                    }).sorted(by: { notificationType1, notificationType2 in
                        localized("notification_type.\(notificationType1.code)") < localized("notification_type.\(notificationType2.code)")
                    })
                    if self.notificationType == nil {
                        self.notificationType = self.notificationTypes[0]
                    }
                    self.fetchUserValidators()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserValidators() {
        self.appService.getUserValidators()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.dataFetchState = .error(error: error)
                } else if let userValidators = response.value {
                    self.userValidators = userValidators
                    self.fetchUserNotificationRules()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserNotificationRules() {
        self.appService.getUserNotificationRules()
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    self.dataFetchState = .error(error: error)
                } else if let userNotificationRules = response.value {
                    self.userNotificationRules = userNotificationRules
                    self.fetchUserValidatorSummaries()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserValidatorSummaries() {
        self.userValidatorSummaries.removeAll()
        if self.userValidators.isEmpty {
            self.dataFetchState = .success(result: "")
            return
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
                    self.dataFetchState = .error(error: error)
                } else if let validatorSummaryReport = response.value {
                    let validatorSummary = validatorSummaryReport.validatorSummary
                    if let userValidator = self.userValidators.first(where: { userValidator in
                        return userValidator.networkId == validatorSummary.networkId
                        && userValidator.validatorAccountId == validatorSummary.accountId
                    }) {
                        self.userValidatorSummaries.append(UserValidatorSummary(
                            userValidator: userValidator,
                            validatorSummary: validatorSummary
                        ))
                        self.filteredUserValidatorSummaries = self.userValidatorSummaries
                        self.sortUserValidatorSummaries()
                    }
                    self.dataFetchState = .success(result: "")
                }
            }
            .store(in: &cancellables)
    }
    
    private func sortUserValidatorSummaries() {
        self.filteredUserValidatorSummaries.sort {
            return $0.validatorSummary.compare(sortOption: .identity, $1.validatorSummary)
        }
    }
    
    private func filterNetworkValidators(network: Network?) {
        if let network = network {
            self.filteredUserValidatorSummaries = self.userValidatorSummaries.filter({ validator in
                validator.validatorSummary.networkId == network.id
            })
        } else {
            self.filteredUserValidatorSummaries = self.userValidatorSummaries
        }
    }
    
    func getUserNotificationRuleByType(typeCode: String) -> UserNotificationRule? {
        return self.userNotificationRules.first { $0.notificationType.code == typeCode }
    }
    
    func deleteAndCreateRule(channelId: UInt64, onSuccess: (() -> ())? = nil) {
        guard let ruleToDelete = self.getUserNotificationRuleByType(typeCode: self.notificationType.code) else {
            return
        }
        self.dataPersistState = .loading
        appService.deleteUserNotificationRule(id: ruleToDelete.id)
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    log.error("Error deleting notification rule: \(error)")
                    self.dataPersistState = .error(error: error)
                } else {
                    log.info("Successfully deleted notification rule of type \(ruleToDelete.notificationType.code).")
                    self.userNotificationRules.removeAll { $0.id == ruleToDelete.id }
                    Event.userNotificationRuleDeleted.post(ruleToDelete.id)
                    self.createRule(channelId: channelId, onSuccess: onSuccess)
                }
            }
            .store(in: &self.cancellables)
    }
    
    func createRule(channelId: UInt64, onSuccess: (() -> ())? = nil) {
        self.dataPersistState = .loading
        var userValidatorIds: [UInt64] = []
        if let validator = self.validator {
            userValidatorIds.append(validator.userValidator.id)
        }
        let request = CreateUserNotificationRuleRequest(
            notificationTypeCode: self.notificationType.code,
            name: nil,
            networkId: self.network?.id,
            isForAllValidators: self.validator == nil,
            userValidatorIds: userValidatorIds,
            periodType: self.periodType,
            period: self.period,
            userNotificationChannelIds: [channelId],
            parameters: [],
            notes: nil
        )
        appService.createUserNotificationRule(request: request)
            .sink {
                [weak self] response in
                guard let self = self else { return }
                if let error = response.error {
                    log.error("Error creating notification rule: \(error)")
                    self.dataPersistState = .error(error: error)
                } else if let userNotificationRule = response.value {
                    log.info("Notification rule created with id \(userNotificationRule.id).")
                    self.dataPersistState = .success(result: "")
                    Event.userNotificationRuleCreated.post(userNotificationRule)
                    onSuccess?()
                }
            }
            .store(in: &self.cancellables)
    }
}
