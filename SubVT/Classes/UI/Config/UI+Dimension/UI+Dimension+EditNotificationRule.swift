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
        static let actionButtonWidth: CGFloat = 165
        static let actionButtonHeight: CGFloat = 52
        static let scrollContentMarginBottom: CGFloat = UI.Dimension.Common.bottomNotchHeight
            + Self.actionButtonHeight
            + 2 * UI.Dimension.Common.padding
        
        static func actionButtonYOffset<T>(
            dataFetchState: DataFetchState<T>,
            dataPersistState: DataFetchState<T>
        ) -> CGFloat {
            switch dataFetchState {
            case .idle, .loading, .error:
                return 150
            case .success:
                switch dataPersistState {
                case .idle, .loading, .success:
                    return -UI.Dimension.Common.bottomNotchHeight - UI.Dimension.Common.padding
                case .error:
                    return 150
                }
            }
        }
        static let validatorListNetworkIconSize: CGFloat = 22
    }
}
