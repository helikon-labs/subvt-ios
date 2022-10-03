//
//  Settings.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import Foundation
import SubVTData

enum AppStorageKey {
    static let hasResetKeychain = "io.subvt.has_reset_keychain"
    static let hasCompletedIntroduction = "io.subvt.has_completed_introduction"
    static let hasBeenOnboarded = "io.subvt.has_been_onboarded"
    static let networks = "io.subvt.networks"
    static let selectedNetwork = "io.subvt.selected_network"
    static let activeValidatorListSortOption = "io.subvt.active_validator_list.sort_option"
    static let inactiveValidatorListSortOption = "io.subvt.active_validator_list.sort_option"
    static let apnsToken = "io.subvt.apns_token"
    static let apnsIsEnabled = "io.subvt.apns_is_enabled"
    static let apnsSetupHasFailed = "io.subvt.apns_setup_has_failed"
    static let hasCompletedAPNSRegistration = "io.subvt.has_completed_apns_registration"
    static let hasCreatedDefaultNotificationRules = "io.subvt.has_created_default_notification_rules"
    static let notificationChannelId = "io.subvt.notification_channel_id"
}
