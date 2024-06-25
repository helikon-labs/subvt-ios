//
//  WKInterfaceDevice.swift
//  SubVT Watch App
//
//  Created by Kutsal Kaan Bilgin on 25.06.2024.
//

import WatchKit

enum WatchModel {
    case w38, w40, w42, w44, w45, unknown
}

extension WKInterfaceDevice {

    static var currentWatchModel: WatchModel {
        switch WKInterfaceDevice.current().screenBounds.size {
        case CGSize(width: 136, height: 170):
            return .w38
        case CGSize(width: 162, height: 197):
            return .w40
        case CGSize(width: 156, height: 195):
            return .w42
        case CGSize(width: 184, height: 224):
            return .w44
        case CGSize(width: 198, height: 242):
            return .w45
        default:
            return .unknown
    }
  }
}
