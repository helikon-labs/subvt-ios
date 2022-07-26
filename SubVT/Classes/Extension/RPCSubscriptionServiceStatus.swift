//
//  RPCSubscriptionServiceStatus.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SubVTData
import SwiftUI

extension RPCSubscriptionServiceStatus {
    var color: Color {
        get {
            switch self {
            case .subscribed(_):
                return Color("StatusActive")
            case .unsubscribed:
                fallthrough
            case .connected:
                return Color("StatusWaiting")
            case .idle:
                return Color("StatusIdle")
            case .disconnected:
                fallthrough
            case .error(_):
                return Color("StatusError")
            }
        }
    }
}
