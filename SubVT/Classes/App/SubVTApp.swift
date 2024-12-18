//
//  SubVTApp.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import Combine
import CoreData
import FirebaseCore
import SubVTData
import SwiftUI
import WatchConnectivity

@main
struct SubVTApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                .environmentObject(appDelegate.router)
                .environmentObject(appDelegate.appState)
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
    @AppStorage(
        AppStorageKey.selectedNetwork,
        store: UserDefaultsUtil.shared
    ) private var selectedNetwork: Network? = nil
    @AppStorage(
        AppStorageKey.watchInitialized,
        store: UserDefaultsUtil.shared
    ) private var watchInitialized = false
    
    let router = Router()
    let appState = AppState()
    
    private var cancellables = Set<AnyCancellable>()
    private let viewContext = PersistenceController.shared.container.viewContext
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.apnsSetupHasFailed = false
        NotificationUtil.createAPNSNotificationChannel(token: token) { channelId in
            self.apnsToken = token
            self.hasCompletedAPNSRegistration = true
            self.notificationChannelId = Int(channelId)
            if !self.hasCreatedDefaultNotificationRules {
                NotificationUtil.createDefaultUserNotificationRules(channelId: channelId) {
                    self.hasCreatedDefaultNotificationRules = true
                } onError: { error in
                    self.apnsSetupHasFailed = true
                }
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
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        initLog()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        return true
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
        let userInfo = response.notification.request.content.userInfo
        if let _ = userInfo["aps"] as? [String: Any],
           let customData = userInfo["notification_data"] as? [String: Any],
           let networkId = customData["network_id"] as? UInt64,
           let notificationTypeCode = customData["notification_type_code"] as? String {
            if let validatorAccountId = customData["validator_account_id"] as? String,
               let validatorDisplay = customData["validator_display"] as? String {
                if notificationTypeCode == "chain_validator_stopped_para_validating" {
                    self.router.push(screen: Screen.paraVoteReport(
                        networkId: networkId,
                        accountId: AccountId(hex: validatorAccountId),
                        identityDisplay: validatorDisplay
                    ))
                } else {
                    self.router.push(screen: Screen.validatorDetails(
                        networkId: networkId,
                        accountId: AccountId(hex: validatorAccountId)
                    ))
                }
            } else {
                self.router.popToRoot()
                self.appState.currentTab = .notifications
            }
        }
        completionHandler()
    }
}

extension AppDelegate: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        switch activationState {
        case .activated:
            log.info("Watch connectivity session activated.")
        case .inactive:
            log.warning("Watch connectivity session is now inactive.")
        case .notActivated:
            log.warning("Watch connectivity session is not actived.")
        @unknown default:
            log.error("Unknown watch connectivity session state: \(activationState)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
    
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {}
    
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {}
    
    func session(
        _ session: WCSession,
        didReceiveMessage message: [String : Any],
        replyHandler: @escaping ([String : Any]) -> Void
    ) {
        var data: [String: Any] = [:]
        let hasBeenOnboarded = self.selectedNetwork != nil
        data[WatchAppStorageKey.hasBeenOnboarded] = hasBeenOnboarded
        if hasBeenOnboarded {
            data[WatchAppStorageKey.privateKey] = KeychainStorage.shared.getPrivateKeyData()
            self.watchInitialized = true
        }
        replyHandler(data)
    }
}
