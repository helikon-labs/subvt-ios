//
//  Settings.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import Foundation
import SubVTData

enum WatchAppStorageKey {
    static let initialSyncInProgress = "io.subvt.watch.initial_sync_in_progress"
    static let initialSyncFailed = "io.subvt.watch.initial_sync_failed"
    static let initialSyncCompleted = "io.subvt.watch.initial_sync_completed"
    static let hasBeenOnboarded = "io.subvt.watch.has_been_onboarded"
    static let networks = "io.subvt.watch.networks"
    static let privateKey = "io.subvt.watch.private_key"
}
