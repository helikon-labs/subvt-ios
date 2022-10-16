//
//  PeriodType.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.10.2022.
//

import Foundation
import SubVTData

extension NotificationPeriodType {
    var display: String {
        switch self {
        case .off:
            return localized("common.off")
        case .immediate:
            return localized("common.immediate")
        case .hour:
            return localized("common.hour")
        case .day:
            return localized("common.day")
        case .epoch:
            return localized("common.epoch")
        case .era:
            return localized("common.era")
        }
    }
}
