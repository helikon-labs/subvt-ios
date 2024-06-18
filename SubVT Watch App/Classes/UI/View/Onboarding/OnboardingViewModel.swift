//
//  OnboardingViewModel.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 17.06.2024.
//

import Combine
import Foundation
import SubVTData
import SwiftUI
import WatchConnectivity

class OnboardingViewModel: ObservableObject {
    @AppStorage(
        WatchAppStorageKey.initialSyncInProgress,
        store: UserDefaultsUtil.shared
    ) private var initialSyncInProgress = false
    @AppStorage(
        WatchAppStorageKey.initialSyncCompleted,
        store: UserDefaultsUtil.shared
    ) private var initialSyncCompleted = false
    @AppStorage(
        WatchAppStorageKey.initialSyncFailed,
        store: UserDefaultsUtil.shared
    ) private var initialSyncFailed = false
    @AppStorage(
        WatchAppStorageKey.hasBeenOnboarded,
        store: UserDefaultsUtil.shared
    ) private var hasBeenOnboarded = false
    
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
}
