//
//  NotificationRulesViewModel.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 30.09.2022.
//

import Combine
import Foundation
import SubVTData

class NotificationRulesViewModel: ObservableObject {
    @Published private(set) var rulesFetchState: DataFetchState<String> = .idle
    @Published private(set) var rules: [UserNotificationRule] = []
    
    private let appService = AppService()
    private var cancellables = Set<AnyCancellable>()
    
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
                self.rulesFetchState = .success(result: "")
            }
        }
        .store(in: &cancellables)
    }
    
}
