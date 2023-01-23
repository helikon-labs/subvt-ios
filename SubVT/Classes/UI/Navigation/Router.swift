//
//  Router.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.01.2023.
//

import Combine
import SubVTData
import SwiftUI

enum Screen: Hashable {
    case validatorList(network: Network, mode: ValidatorListViewModel.Mode)
    case validatorDetails(networkId: UInt64, accountId: AccountId)
    case reportRangeSelection(mode: ReportRangeSelectionView.Mode)
    case rewardReport(
        network: Network,
        accountId: AccountId,
        identityDisplay: String,
        factor: ReportDataFactor,
        title: String,
        chartTitle: String
    )
    case paraVoteReport(
        network: Network,
        accountId: AccountId,
        identityDisplay: String
    )
    case validatorReports(
        network: Network,
        accountId: AccountId,
        identityDisplay: String,
        startEra: Era,
        endEra: Era
    )
    case networkReports(
        network: Network,
        startEra: Era,
        endEra: Era
    )
    case notificationRules
    case createNotificationRule
    case editNotificationRule(
        rule: UserNotificationRule
    )
    case addValidators
    case eraReport(
        type: EraReportView.`Type`,
        data: EraReportView.Data,
        factor: ReportDataFactor,
        title: String,
        chartTitle: String,
        validatorIdentityDisplay: String?,
        network: Network,
        startEra: Era,
        endEra: Era,
        annotate: Bool
    )
    
    @ViewBuilder
    func build() -> some View {
        switch self {
        case .validatorList(let network, let mode):
            ValidatorListView(network: network, mode: mode)
        case .validatorDetails(let networkId, let accountId):
            ValidatorDetailsView(networkId: networkId, accountId: accountId)
        case .reportRangeSelection(let mode):
            ReportRangeSelectionView(mode: mode)
        case .rewardReport(
            let network,
            let accountId,
            let identityDisplay,
            let factor,
            let title,
            let chartTitle
        ):
            RewardReportView(
                network: network,
                accountId: accountId,
                identityDisplay: identityDisplay,
                factor: factor,
                title: title,
                chartTitle: chartTitle
            )
        case .paraVoteReport(
            let network,
            let accountId,
            let identityDisplay
        ):
            ParaVoteReportView(
                network: network,
                accountId: accountId,
                identityDisplay: identityDisplay
            )
        case .validatorReports(
            let network,
            let accountId,
            let identityDisplay,
            let startEra,
            let endEra
        ):
            ValidatorReportsView(
                network: network,
                accountId: accountId,
                identityDisplay: identityDisplay,
                startEra: startEra,
                endEra: endEra
            )
        case .networkReports(let network, let startEra, let endEra):
            NetworkReportsView(
                network: network,
                startEra: startEra,
                endEra: endEra
            )
        case .notificationRules:
            NotificationRulesView()
        case .createNotificationRule:
            EditNotificationRuleView(mode: .create)
        case .editNotificationRule(let rule):
            EditNotificationRuleView(mode: .edit(rule: rule))
        case .addValidators:
            AddValidatorsView()
        case .eraReport(
            let type,
            let data,
            let factor,
            let title,
            let chartTitle,
            let validatorIdentityDisplay,
            let network,
            let startEra,
            let endEra,
            let annotate
        ):
            EraReportView(
                type: type,
                data: data,
                factor: factor,
                title: title,
                chartTitle: chartTitle,
                validatorIdentityDisplay: validatorIdentityDisplay,
                network: network,
                startEra: startEra,
                endEra: endEra,
                annotate: annotate
            )
        }
    }
}

final class Router : ObservableObject {
    @Published var path: [Screen] = []
    
    func popToRoot() {
        self.path = []
    }
    
    func push(screen: Screen) {
        self.path.append(screen)
    }
    
    func back() {
        self.path.removeLast()
    }
}
