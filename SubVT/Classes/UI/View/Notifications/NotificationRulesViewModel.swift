//
//  NotificationRulesViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import Combine
import Foundation
import SubVTData
import SwiftEventBus

class NotificationRulesViewModel: ObservableObject {
    @Published private(set) var rulesFetchState: DataFetchState<String> = .idle
    @Published private(set) var rules: [UserNotificationRule] = []
    
    private let appService = AppService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        SwiftEventBus.onMainThread(self, name: Event.userNotificationRuleDeleted.rawValue) {
            [weak self] result in
            guard let self = self, let id = result?.object as? UInt64 else { return }
            self.rules.removeAll { $0.id == id }
        }
        SwiftEventBus.onMainThread(self, name: Event.userNotificationRuleCreated.rawValue) {
            [weak self] result in
            guard let self = self, let rule = result?.object as? UserNotificationRule else { return }
            self.rules.append(rule)
            self.sortRules()
        }
    }
    
    func fetchRules() {
        guard self.rulesFetchState != .loading else { return }
        self.rulesFetchState = .loading
        self.appService.getUserNotificationRules().sink {
            [weak self]
            response in
            guard let self = self else { return }
            if let error = response.error {
                self.rulesFetchState = .error(error: error)
            } else if let rules = response.value {
                self.rules = rules
                self.sortRules()
                self.rulesFetchState = .success(result: "")
            }
        }
        .store(in: &cancellables)
    }
    
    private func sortRules() {
        self.rules.sort(by: { rule1, rule2 in
            localized("notification_type.\(rule1.notificationType.code)") < localized("notification_type.\(rule2.notificationType.code)")
        })
    }
    
    func deleteRule(
        _ toDelete: UserNotificationRule,
        onComplete: @escaping (Bool) -> ()
    ) {
        self.rules.removeAll { existing in
            return existing.id == toDelete.id
        }
        self.appService
            .deleteUserNotificationRule(id: toDelete.id)
            .sink { response in
                if let _ = response.error {
                    onComplete(false)
                    self.rules.append(toDelete)
                    self.sortRules()
                } else {
                    onComplete(true)
                }
            }
            .store(in: &cancellables)
    }
    
}
