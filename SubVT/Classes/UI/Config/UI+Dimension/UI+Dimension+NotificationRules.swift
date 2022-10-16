//
//  UI+Dimension+NotificationRules.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.10.2022.
//

import SwiftUI

extension UI.Dimension {
    enum NotificationRules {
        static let actionFeedbackViewYOffset = -UI.Dimension.Common.bottomNotchHeight - UI.Dimension.Common.padding
        static let snackbarHiddenYOffset: CGFloat = 92
        static let snackbarVisibleYOffset = -UI.Dimension.Common.bottomNotchHeight - UI.Dimension.Common.padding
        static let addRuleButtonWidth: CGFloat = 266
        static let addRuleButtonHeight: CGFloat = 50
        static let addValidatorsButtonWidth: CGFloat = 266
        static let addValidatorsButtonHeight: CGFloat = 50
        static let addValidatorsButtonYOffset: CGFloat = -(UI.Dimension.Common.bottomNotchHeight
                                                          + UI.Dimension.Common.padding)
    }
}
