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
    }
}
