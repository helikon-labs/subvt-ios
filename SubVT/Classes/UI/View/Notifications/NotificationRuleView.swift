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
            Text(self.rule.periodType.rawValue)
                .font(UI.Font.NotificationRules.info)
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
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
