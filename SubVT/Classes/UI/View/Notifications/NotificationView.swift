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
    //@State private(set) var isExpanded = false
    
    private let notification: Notification
    private let onRead: (() -> ())?
    private let dateFormatter: DateFormatter
    
    init(notification: Notification, onRead: (() -> ())? = nil) {
        self.notification = notification
        self.onRead = onRead
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "HH:mm MMM dd, yyyy"
    }
    
    private var message: String {
        let message = self.notification.message ?? ""
        if let validatorDisplay = self.notification.validatorDisplay {
            return message.replacingOccurrences(
                of:  validatorDisplay,
                with: ""
            ).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var title: String {
        if let validatorDisplay = self.notification.validatorDisplay {
            return validatorDisplay
        } else if let notificationTypeCode = self.notification.notificationTypeCode,
                  notificationTypeCode.contains("democracy") {
            return localized("common.democracy")
        }
        return ""
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(self.title)
                    .font(UI.Font.Notification.validatorDisplay)
                    .foregroundColor(Color("Text"))
                Spacer()
                if let network = networks?.first(where: { network in
                    network.id == notification.networkId
                   }) {
                    UI.Image.Common.networkIcon(network: network)
                        .resizable()
                        .frame(width: 18, height: 18)
                } else {
                    EmptyView()
                }
                /*
                if self.isExpanded {
                    UI.Image.Common.arrowUp(self.colorScheme)
                } else {
                    UI.Image.Common.arrowDown(self.colorScheme)
                }
                 */
            }
            Spacer()
                .frame(height: 8)
            HStack {
                Text(self.message)
                    .font(UI.Font.Notification.notificationMessage)
                    .foregroundColor(Color("Text"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            Spacer()
                .frame(height: 6)
            HStack {
                /*
                if let notificationTypeCode = notification.notificationTypeCode {
                    Text(localized("notification_type.\(notificationTypeCode)"))
                        .font(UI.Font.Notification.notificationType)
                        .foregroundColor(Color("Text"))
                } else {
                    Spacer()
                }
                 */
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
        /*
        .onTapGesture {
            self.isExpanded.toggle()
            if self.isExpanded {
                self.onRead?()
            }
        }
         */
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(notification: PreviewData.notification)
    }
}
