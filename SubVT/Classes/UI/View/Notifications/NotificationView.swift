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
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage(AppStorageKey.networks) private var networks: [Network]? = nil
    @State private(set) var isExpanded = false
    
    private let notification: Notification
    private let onRead: (() -> ())?
    private let dateFormatter: DateFormatter
    
    init(notification: Notification, onRead: (() -> ())? = nil) {
        self.notification = notification
        self.onRead = onRead
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
            if self.isExpanded {
                Spacer()
                    .frame(height: 8)
                HStack {
                    Text((self.notification.message ?? "-").trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ))
                        .font(UI.Font.Notification.notificationMessage)
                        .foregroundColor(Color("Text"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                }
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
        .onTapGesture {
            self.isExpanded.toggle()
            if self.isExpanded {
                self.onRead?()
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(notification: PreviewData.notification)
    }
}
