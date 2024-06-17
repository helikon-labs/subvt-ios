//
//  WatchConnectivityUtil.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 10.06.2024.
//

import Foundation
import WatchConnectivity

typealias OptionalHandler<T> = ((T) -> Void)?

private func optionalMainQueueDispatch<T>(
    handler: OptionalHandler<T>
) -> OptionalHandler<T> {
    guard let handler = handler else {
        return nil
    }

    return { item in
        DispatchQueue.main.async {
            handler(item)
        }
    }
}

enum WatchConnectivityMessageKey {
    static let syncInitialContext = "io.subvt.wc.sync_initial_context"
}

enum WatchConnectivityDeliveryPriority {
    case message
    case userInfo
    case applicationContext
}

struct WatchConnectivityUtil {
    static func send(
        data: [String: Any],
        priority: WatchConnectivityDeliveryPriority,
        replyHandler: (([String: Any]) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        guard WCSession.default.activationState == .activated else {
            log.warning("Cannot send watch connectivity message: Session is not activated.")
            return
        }
        switch priority {
        case .message:
            WCSession.default.sendMessage(
                data,
                replyHandler: optionalMainQueueDispatch(handler: replyHandler),
                errorHandler: optionalMainQueueDispatch(handler: errorHandler)
            )
        case .userInfo:
            WCSession.default.transferUserInfo(data)
        case .applicationContext:
            do {
                try WCSession.default.updateApplicationContext(data)
            } catch {
                errorHandler?(error)
            }
        }
    }
}
