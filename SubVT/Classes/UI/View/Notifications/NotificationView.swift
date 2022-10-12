//
//  NotificationView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 9.10.2022.
//

import SubVTData
import SwiftUI

struct NotificationView: View {
    @Environment (\.colorScheme) private var colorScheme: ColorScheme
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @State private(set) var isExpanded = false
    
    private let notification: Notification
    private let dateFormatter: DateFormatter
    
    init(notification: Notification) {
        self.notification = notification
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "HH:mm MMM dd, yyyy"
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(notification.validatorDisplay ?? "-")
                    .font(UI.Font.Notification.validatorDisplay)
                    .foregroundColor(Color("Text"))
                Spacer()
                if let networkId = notification.networkId,
                   let network = networks?.first(where: { network in
                       network.id == networkId
                   }) {
                    UI.Image.Common.networkIcon(network: network)
                        .resizable()
                        .frame(width: 18, height: 18)
                } else {
                    EmptyView()
                }
                if self.isExpanded {
                    UI.Image.Common.arrowUp(self.colorScheme)
                } else {
                    UI.Image.Common.arrowDown(self.colorScheme)
                }
            }
            Spacer()
                .frame(height: 12)
            HStack {
                if let notificationTypeCode = notification.notificationTypeCode {
                    Text(localized("notification_type.\(notificationTypeCode)"))
                        .font(UI.Font.Notification.notificationType)
                        .foregroundColor(Color("Text"))
                } else {
                    Spacer()
                }
                Spacer()
                Text(notification.receivedAt ?? Date(), formatter: self.dateFormatter)
                    .font(UI.Font.Notification.notificationType)
                    .foregroundColor(Color("Text"))
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(
            top: UI.Dimension.Notification.padding,
            leading: UI.Dimension.Notification.padding,
            bottom: UI.Dimension.Notification.padding,
            trailing: UI.Dimension.Notification.padding
        ))
        .background(Color("DataPanelBg"))
        .cornerRadius(16)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(notification: PreviewData.notification)
    }
}
