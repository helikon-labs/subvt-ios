//
//  NotificationRuleView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.10.2022.
//

import SubVTData
import SwiftUI

struct NotificationRuleView: View {
    private var rule: UserNotificationRule
    
    init(rule: UserNotificationRule) {
        self.rule = rule
    }
    
    private var networkDisplay: String {
        return self.rule.network?.display ?? localized("notification_rules.all_networks")
    }
    
    private var validatorDisplay: String {
        if self.rule.validators.count == 0 {
            return localized("notification_rules.all_validators")
        } else if self.rule.validators.count == 1 {
            return localized("notification_rules.one_validator")
        }  else {
            return String(
                format: localized("notification_rules.n_validators"),
                self.rule.validators.count
            )
        }
    }
    
    private var periodDisplay: String {
        switch self.rule.periodType {
        case .off:
            return localized("notification_rules.off")
        case .immediate:
            return localized("common.immediate")
        case .epoch:
            if self.rule.period == 1 {
                return localized("notification_rules.every_epoch")
            } else {
                return String(
                    format: localized("notification_rules.every_n_epochs"),
                    self.rule.period
                )
            }
        case .era:
            if self.rule.period == 1 {
                return localized("notification_rules.every_era")
            } else {
                return String(
                    format: localized("notification_rules.every_n_eras"),
                    self.rule.period
                )
            }
        case .hour:
            if self.rule.period == 1 {
                return localized("notification_rules.every_hour")
            } else {
                return String(
                    format: localized("notification_rules.every_n_hours"),
                    self.rule.period
                )
            }
        case .day:
            if self.rule.period == 1 {
                return localized("notification_rules.every_day")
            } else {
                return String(
                    format: localized("notification_rules.every_n_days"),
                    self.rule.period
                )
            }
        }
    }
    
    private var periodColor: Color {
        switch self.rule.periodType {
        case .off:
            return Color("StatusError")
        default:
            return Color("Text")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(localized("notification_type.\(self.rule.notificationType.code)"))
                .font(UI.Font.NotificationRules.title)
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                .frame(height: 8)
            HStack(spacing: 4) {
                Text(self.networkDisplay)
                    .font(UI.Font.NotificationRules.info)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                Text("/")
                    .font(UI.Font.NotificationRules.info)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                Text(self.validatorDisplay)
                    .font(UI.Font.NotificationRules.info)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("/")
                    .font(UI.Font.NotificationRules.info)
                    .foregroundColor(Color("Text"))
                    .lineLimit(1)
                Text(self.periodDisplay)
                    .font(UI.Font.NotificationRules.info)
                    .foregroundColor(self.periodColor)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("DataPanelBg"))
        .cornerRadius(16)
    }
}

struct NotificationRuleView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRuleView(rule: PreviewData.notificationRule)
    }
}
