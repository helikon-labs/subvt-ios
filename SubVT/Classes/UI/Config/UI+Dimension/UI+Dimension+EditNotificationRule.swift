//
//  EditNotificationRule.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 14.10.2022.
//

import SwiftUI

extension UI.Dimension {
    enum EditNotificationRule {
        static let scrollContentMarginTop: CGFloat = UI.Dimension.Common.titleMarginTop + 48 + UI.Dimension.Common.padding
        static let subSelectionScrollViewMaxHeight = UI.Dimension(250, 400)
        static let actionButtonYOffset = -UI.Dimension.Common.bottomNotchHeight
            - UI.Dimension.Common.padding
        static let actionButtonWidth: CGFloat = 165
        static let actionButtonHeight: CGFloat = 52
    }
}
