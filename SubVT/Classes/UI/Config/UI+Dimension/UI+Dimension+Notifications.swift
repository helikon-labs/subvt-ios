//
//  UI+Dimension+Notifications.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.10.2022.
//

import SwiftUI

extension UI.Dimension {
    enum Notifications {
        static let enableNotificationsButtonWidth: CGFloat = 266
        static let enableNotificationsButtonHeight: CGFloat = 50
        static let scrollContentMarginTop: CGFloat = UI.Dimension.Common.titleMarginTop + 48 + UI.Dimension.Common.padding
        static let scrollContentBottomSpacerHeight: CGFloat = UI.Dimension.TabBar.marginBottom
            + UI.Dimension.TabBar.height
            + UI.Dimension.Common.padding
    }
    
    enum Notification {
        static let padding: CGFloat = 16
    }
}
