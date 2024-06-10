//
//  Notification.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.10.2022.
//

import Combine
import CoreData
import Foundation
import SubVTData
import SwiftUI

struct NotificationUtil {
    static private let appService = AppService()
    static private var cancellables = Set<AnyCancellable>()
    
    static func apnsIsEnabled(onComplete: @escaping ((Bool) -> ())) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .denied:
                onComplete(false)
            default:
                onComplete(true)
            }
        }
    }
    
    static func requestAPNSAuthorization(onComplete: @escaping ((Bool) -> ())) {
        NotificationUtil.apnsIsEnabled { isEnabled in
            if isEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .badge, .sound]
                    ) { (granted, _) in
                        DispatchQueue.main.async {
                            onComplete(granted)
                        }
                    }
                }
            }
        }
    }
    
    static func createAPNSNotificationChannel(
        token: String,
        onSuccess: @escaping (UInt64) -> (),
        onError: @escaping (APIError) -> ()
    ) {
        NotificationUtil.appService.createUserNotificationChannel(
            channel: NewUserNotificationChannel(
                channel: .apns,
                target: token
            )
        ).sink { (response) in
            if let error = response.error {
                log.error("Error while creating APNS notification channel: \(error)")
                onError(error)
            } else {
                switch response.result {
                case .success(let channel):
                    log.info("Successfully created APNS notification channel with id \(channel.id).")
                    onSuccess(channel.id)
                case .failure(let error):
                    log.error("Error while creating APNS notification channel: \(error)")
                    onError(error)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    static func createDefaultUserNotificationRules(
        channelId: UInt64,
        onSuccess: @escaping () -> (),
        onError: @escaping (APIError) -> ()
    ) {
        NotificationUtil.appService.createDefaultUserNotificationRules(
            channelId: channelId
        )
        .sink { (response) in
            if let error = response.error {
                log.error("Error while creating default notification rules: \(error)")
                onError(error)
            } else {
                switch response.result {
                case .success:
                    log.info("Successfully created default notification rules.")
                    onSuccess()
                case .failure(let error):
                    log.error("Error while creating default notification rules: \(error)")
                    onError(error)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    static func deleteUserNotificationChannel(
        channelId: UInt64,
        onSuccess: @escaping () -> (),
        onError: @escaping (APIError) -> ()
    ) {
        NotificationUtil.appService.deleteUserNotificationChannel(
            id: channelId
        )
        .sink { (response) in
            if let error = response.error {
                log.error("Error while deleting user notification channel: \(error)")
                onError(error)
            } else {
                switch response.result {
                case .success:
                    log.info("Successfully deleted user notification channel.")
                    onSuccess()
                case .failure(let error):
                    log.error("Error while deleting user notification channel: \(error)")
                    onError(error)
                }
            }
        }
        .store(in: &cancellables)
    }
    
    static func updateAppNotificationBadge(context: NSManagedObjectContext) {
        do {
            let fetchRequest : NSFetchRequest<Notification> = Notification.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "isRead == %@",
                NSNumber(value: false)
            )
            let count = try context.count(for: fetchRequest)
            UIApplication.shared.applicationIconBadgeNumber = count
        } catch {
            log.error("Error while updating app badge: \(error)")
        }
    }
}
