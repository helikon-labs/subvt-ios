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
            if !UserDefaultsUtil.shared.bool(forKey: WatchAppStorageKey.initialSyncCompleted) {
                self.sendInitialSyncMessage()
            }
        } else {
            log.info("Watch connectivity session is now unreachable.")
        }
    }
    
    private func sendInitialSyncMessage() {
        guard WCSession.default.isReachable else {
            return
        }
        guard !UserDefaultsUtil.shared.bool(forKey: WatchAppStorageKey.initialSyncCompleted) else {
            return
        }
        UserDefaultsUtil.shared.set(false, forKey: WatchAppStorageKey.initialSyncFailed)
        UserDefaultsUtil.shared.set(true, forKey: WatchAppStorageKey.initialSyncInProgress)
        WatchConnectivityUtil.send(
            data: [WatchConnectivityMessageKey.syncInitialContext: true],
            priority: .message,
            replyHandler: { reply in
                log.info("Initial sync reply received.")
                UserDefaultsUtil.shared.set(false, forKey: WatchAppStorageKey.initialSyncInProgress)
                UserDefaultsUtil.shared.set(false, forKey: WatchAppStorageKey.initialSyncFailed)
                UserDefaultsUtil.shared.set(true, forKey: WatchAppStorageKey.initialSyncCompleted)
                let hasBeenOnboarded = reply[WatchAppStorageKey.hasBeenOnboarded] as? Bool ?? false
                UserDefaultsUtil.shared.set(hasBeenOnboarded, forKey: WatchAppStorageKey.hasBeenOnboarded)
            },
            errorHandler: { error in
                UserDefaultsUtil.shared.set(false, forKey: WatchAppStorageKey.initialSyncInProgress)
                UserDefaultsUtil.shared.set(true, forKey: WatchAppStorageKey.initialSyncFailed)
            }
        )
    }
    
    private func update(from dictionary: [String: Any]) {
        if let hasBeenOnboarded = dictionary[WatchAppStorageKey.hasBeenOnboarded] as? Bool {
            UserDefaultsUtil.shared.set(hasBeenOnboarded, forKey: WatchAppStorageKey.hasBeenOnboarded)
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
        log.info("Session did receive user info: \(userInfo)")
        update(from: userInfo)
    }
    
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        log.info("Session did receive application context: \(applicationContext)")
        update(from: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        log.info("Session did receive message: \(message)")
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
