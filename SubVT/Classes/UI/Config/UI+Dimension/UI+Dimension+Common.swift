//
//  UI+Dimension+Common.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum Common {
        static var cornerRadius: CGFloat = 12
        static var horizontalPadding: CGFloat = 16
        static var actionButtonWidth: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 266
                } else {
                    return 272
                }
            }
        }
        static let actionButtonHeight: CGFloat = 64
        static let lineSpacing: CGFloat = 4
        static var actionButtonMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return .infinity
                } else {
                    return 40
                }
            }
        }
        static let actionButtonMarginBottom: CGFloat = 16
        
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
        
        static func actionButtonYOffset(displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return 70
            case .appeared:
                return 0
            case .dissolved:
                return 70
            }
        }
    }
}
