//
//  SubVT_WatchApp.swift
//  SubVT Watch Watch App
//
//  Created by Kutsal Kaan Bilgin on 11.02.2024.
//

import SubVTData
import SwiftUI
import WatchKit
import WatchConnectivity

class MyWatchAppDelegate: NSObject, WKApplicationDelegate {
    @AppStorage(
        WatchAppStorageKey.initialSyncCompleted,
        store: UserDefaultsUtil.shared
    ) private var initialSyncCompleted = false
    @AppStorage(
        WatchAppStorageKey.initialSyncFailed,
        store: UserDefaultsUtil.shared
    ) private var initialSyncFailed = false
    @AppStorage(
        WatchAppStorageKey.initialSyncInProgress,
        store: UserDefaultsUtil.shared
    ) private var initialSyncInProgress = false
    @AppStorage(
        WatchAppStorageKey.hasBeenOnboarded,
        store: UserDefaultsUtil.shared
    ) private var hasBeenOnboarded = false
    
    func applicationDidFinishLaunching() {
        initLog()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
}

extension MyWatchAppDelegate: WCSessionDelegate {
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
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            log.info("Watch connectivity session is now reachable.")
            if !self.initialSyncCompleted {
                self.sendInitialSyncMessage()
            }
        } else {
            log.info("Watch connectivity session is now unreachable.")
        }
    }
    
    func sendInitialSyncMessage() {
        guard WCSession.default.isReachable else {
            return
        }
        guard !self.initialSyncCompleted else {
            return
        }
        self.initialSyncFailed = false
        self.initialSyncInProgress = true
        WatchConnectivityUtil.send(
            data: [WatchConnectivityMessageKey.syncInitialContext: true],
            priority: .message,
            replyHandler: { reply in
                log.info("Initial sync reply received.")
                self.initialSyncInProgress = false
                self.initialSyncFailed = false
                self.initialSyncCompleted = true
                self.update(from: reply)
            },
            errorHandler: { error in
                self.initialSyncInProgress = false
                self.initialSyncFailed = true
            }
        )
    }
    
    private func update(from dictionary: [String: Any]) {
        if let hasBeenOnboarded = dictionary[WatchAppStorageKey.hasBeenOnboarded] as? Bool {
            self.hasBeenOnboarded = hasBeenOnboarded
            return
        }
        if let privateKey = dictionary[WatchAppStorageKey.privateKey] as? Data {
            KeychainStorage.shared.setPrivateKey(data: privateKey)
        }
    }
    
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        log.info("Watch connectivity session received user info: \(userInfo)")
        update(from: userInfo)
    }
    
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        log.info("Watch connectivity session received application context: \(applicationContext)")
        update(from: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        log.info("Watch connectivity session received message: \(message)")
    }
}

@main
struct WatchApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: MyWatchAppDelegate
    
    var body: some Scene {
        WindowGroup {
            WatchAppView()
                .defaultAppStorage(UserDefaultsUtil.shared)
        }
    }
}
