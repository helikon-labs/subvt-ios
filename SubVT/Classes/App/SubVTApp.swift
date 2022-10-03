//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import Combine
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
}
