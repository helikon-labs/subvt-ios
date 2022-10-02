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
                .defaultAppStorage(UserDefaults(
                    suiteName: "io.helikon.subvt.user_defaults"
                )!)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage(AppStorageKey.apnsToken) private var apnsToken = ""
    @AppStorage(AppStorageKey.hasCompletedAPNSRegistration) private var hasCompletedAPNSRegistration = false
    @AppStorage(AppStorageKey.hasCreatedDefaultNotificationRules) private var hasCreatedDefaultNotificationRules = false
    @AppStorage(AppStorageKey.notificationChannelId) private var notificationChannelId = 0
    private var cancellables = Set<AnyCancellable>()
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard !self.hasCompletedAPNSRegistration else { return }
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.apnsToken = token
        NotificationUtil.createAPNSNotificationChannel(token: token) { channelId in
            self.hasCompletedAPNSRegistration = true
            self.notificationChannelId = Int(channelId)
            NotificationUtil.createDefaultUserNotificationRules(channelId: channelId) {
                self.hasCreatedDefaultNotificationRules = true
            } onError: { error in
                print("err \(error)")
            }
        } onError: { error in
            print("err \(error)")
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNS registration error: \(error)")
    }
}
