//
//  UI+Dimension+ReportRangeSelection.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 23.11.2022.
//

import Foundation

extension UI.Dimension {
    enum ReportRangeSelection {
        static let networkIconSize = UI.Dimension(24, 24)
        static let viewButtonWidth: CGFloat = 266
        static let viewButtonHeight: CGFloat = 52
        static func viewButtonMarginBottom(
            mode: ReportRangeSelectionView.Mode
        ) -> CGFloat {
            switch mode {
            case .network:
                return UI.Dimension.TabBar.marginBottom
                    + UI.Dimension.TabBar.height
                    + UI.Dimension.Common.padding
            case .validator:
                return UI.Dimension.Common.bottomNotchHeight
                + UI.Dimension.Common.padding
            }
        }
        static let eraListHeight: CGFloat = 300
        static let scrollViewBottomSpacerHeight = UI.Dimension.TabBar.marginBottom
            + UI.Dimension.TabBar.height
            + UI.Dimension.Common.padding
            + viewButtonHeight
            + UI.Dimension.Common.padding
    }
}
