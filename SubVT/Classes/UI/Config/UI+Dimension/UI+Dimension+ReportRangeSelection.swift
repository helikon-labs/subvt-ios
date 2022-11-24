//
//  UI+Dimension+ReportRangeSelection.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 23.11.2022.
//

import Foundation

extension UI.Dimension {
    enum ReportRangeSelection {
        static func snackbarYOffset<T>(fetchState: DataFetchState<T>) -> CGFloat {
            switch fetchState {
            case .idle:
                fallthrough
            case .loading:
                fallthrough
            case .success:
                return 92
            case .error:
                return -UI.Dimension.Common.bottomNotchHeight - UI.Dimension.TabBar.height - UI.Dimension.Common.padding
            }
        }
        
        static func snackbarOpacity<T>(fetchState: DataFetchState<T>) -> Double {
            switch fetchState {
            case .idle:
                fallthrough
            case .loading:
                fallthrough
            case .success:
                return 0
            case .error:
                return 1
            }
        }
        
        static let networkIconSize = UI.Dimension(24, 24)
        static let viewButtonWidth: CGFloat = 266
        static let viewButtonHeight: CGFloat = 52
        static let viewButtonMarginBottom = UI.Dimension.TabBar.marginBottom
            + UI.Dimension.TabBar.height
            + UI.Dimension.Common.padding
        static let eraListHeight: CGFloat = 300
        static let scrollViewBottomSpacerHeight = UI.Dimension.TabBar.marginBottom
            + UI.Dimension.TabBar.height
            + UI.Dimension.Common.padding
            + viewButtonHeight
            + UI.Dimension.Common.padding
    }
}
