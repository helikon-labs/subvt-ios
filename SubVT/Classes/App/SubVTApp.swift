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
                .defaultAppStorage(UserDefaults.init(
                    suiteName: "io.helikon.subvt.user_defaults"
                )!)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    @AppStorage(AppStorageKey.hasCompletedAPNSRegistration) private var hasCompletedAPNSRegistration = false
    private var cancellables = Set<AnyCancellable>()
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        guard !self.hasCompletedAPNSRegistration else { return }
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        AppService().createUserNotificationChannel(
            channel: NewUserNotificationChannel(
                channel: .apns,
                target: token
            )
        ).sink { (response) in
            if let error = response.error {
                print("APNS backend error: \(error)")
            } else {
                print("APNS backend success.")
                self.hasCompletedAPNSRegistration = true
            }
        }
        .store(in: &cancellables)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("APNS registration error: \(error)")
    }
}
