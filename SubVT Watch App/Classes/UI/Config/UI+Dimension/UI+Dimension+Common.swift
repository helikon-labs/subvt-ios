//
//  UI+Dimension+ValidatorList.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SwiftUI

extension UI.Dimension {
    
    enum Common {
        static let cornerRadius: CGFloat = 12
        static let listItemSpacing: CGFloat = 8
        static var padding: CGFloat = 12
        static let lineSpacing: CGFloat = 3
        static var connectionStatusSize: CGFloat = 4
        static let lineChartLineWidth: CGFloat = 2
        static func dataPanelYOffset(_ displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return 12
            case .appeared:
                return 0
            case .dissolved:
                return 12
            }
        }
        static func displayStateOpacity(_ displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return 0
            case .appeared:
                return 1
            case .dissolved:
                return 0
            }
        }
        static let dataPanelSpacing: CGFloat = 4
        static let dataPanelCornerRadius: CGFloat = 8
        static let dataPanelPadding: CGFloat = 8
        static let dataPanelContentMarginTop: CGFloat = 6
    }
}
