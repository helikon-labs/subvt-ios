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
    }
}
