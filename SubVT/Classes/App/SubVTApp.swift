//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import Combine
import CoreData
import SubVTData
import SwiftUI

@main
struct SubVTApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                .defaultAppStorage(UserDefaultsUtil.shared)
                .onAppear() {
                    UNUserNotificationCenter.current().delegate = appDelegate
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage(
        AppStorageKey.apnsToken,
        store: UserDefaultsUtil.shared
    ) private var apnsToken = ""
    @AppStorage(
        AppStorageKey.apnsSetupHasFailed,
        store: UserDefaultsUtil.shared
    ) private var apnsSetupHasFailed = false
    @AppStorage(
        AppStorageKey.hasCompletedAPNSRegistration,
        store: UserDefaultsUtil.shared
    ) private var hasCompletedAPNSRegistration = false
    @AppStorage(
        AppStorageKey.hasCreatedDefaultNotificationRules,
        store: UserDefaultsUtil.shared
    ) private var hasCreatedDefaultNotificationRules = false
    @AppStorage(
        AppStorageKey.notificationChannelId,
        store: UserDefaultsUtil.shared
    ) private var notificationChannelId = 0
    private var cancellables = Set<AnyCancellable>()
    private let viewContext = PersistenceController.shared.container.viewContext
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.apnsToken = token
        self.apnsSetupHasFailed = false
        NotificationUtil.createAPNSNotificationChannel(token: token) { channelId in
            self.hasCompletedAPNSRegistration = true
            self.notificationChannelId = Int(channelId)
            NotificationUtil.createDefaultUserNotificationRules(channelId: channelId) {
                self.hasCreatedDefaultNotificationRules = true
            } onError: { error in
                self.apnsSetupHasFailed = true
            }
        } onError: { error in
            self.apnsSetupHasFailed = true
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        log.error("APNS registration error: \(error)")
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        log.info("Received push notification.")
        if let apsData = userInfo["aps"] as? [String: Any],
           let customData = userInfo["notification_data"] as? [String: Any],
           let networkId = customData["network_id"] as? Int32,
           let notificationTypeCode = customData["notification_type_code"] as? String {
            let notification = Notification(context: self.viewContext)
            notification.id = UUID()
            notification.isRead = false
            notification.receivedAt = Date()
            if let message = apsData["alert"] as? String {
                notification.message = message
            } else {
                notification.message = ""
            }
            notification.networkId = networkId
            notification.notificationTypeCode = notificationTypeCode
            notification.validatorAccountId = customData["validator_account_id"] as? String
            notification.validatorDisplay = customData["validator_display"] as? String
            try? self.viewContext.save()
        }
        NotificationUtil.updateAppNotificationBadge(
            context: self.viewContext
        )
        completionHandler(.noData)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // process notification
        completionHandler()
    }
}
