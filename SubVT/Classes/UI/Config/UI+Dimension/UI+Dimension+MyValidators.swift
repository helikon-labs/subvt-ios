//
//  UI+Dimension+MyValidators.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 23.08.2022.
//

import SwiftUI

extension UI.Dimension {
    enum MyValidators {
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
        
        static let scrollContentMarginTop: CGFloat = UI.Dimension.Common.titleMarginTop + 48 + UI.Dimension.Common.padding
        static let scrollContentBottomSpacerHeight: CGFloat = UI.Dimension.TabBar.marginBottom
            + UI.Dimension.TabBar.height
            + UI.Dimension.Common.padding
            + addValidatorsButtonHeight
            + UI.Dimension.Common.padding
        static let addValidatorsButtonWidth: CGFloat = 266
        static let addValidatorsButtonHeight: CGFloat = 50
        static let addValidatorsButtonYOffset: CGFloat = -(UI.Dimension.TabBar.marginBottom
                                                          + UI.Dimension.TabBar.height
                                                          + UI.Dimension.Common.padding)
    }
}
