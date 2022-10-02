//
//  Notification.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.10.2022.
//

import Combine
import Foundation
import SubVTData
import SwiftUI

struct NotificationUtil {
    static private let appService = AppService()
    static private var cancellables = Set<AnyCancellable>()
    
    static func setupAPNS() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .denied:
              break
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: [.alert, .sound]
                    ) { (granted, _) in
                        guard granted else { return }
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
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
                onError(error)
            } else {
                switch response.result {
                case .success(let channel):
                    onSuccess(channel.id)
                case .failure(let error):
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
                onError(error)
            } else {
                switch response.result {
                case .success:
                    onSuccess()
                case .failure(let error):
                    onError(error)
                }
            }
        }
        .store(in: &cancellables)
    }
}
