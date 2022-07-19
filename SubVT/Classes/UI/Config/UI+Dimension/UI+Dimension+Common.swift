//
//  UI+Dimension+Common.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum Common {
        static let cornerRadius: CGFloat = 12
        static var titleMarginTop: CGFloat {
            get {
                if UIApplication.hasTopNotch {
                    return 70
                } else {
                    return 40
                }
            }
        }
        static var contentAfterTitleMarginTop: CGFloat {
            get {
                return titleMarginTop + 68
            }
        }
        static var padding: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 16
                } else {
                    return 32
                }
            }
        }
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
                return 180
            }
        }
        
        static var dataPanelSpacing: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 8
                } else {
                    return 16
                }
            }
        }
        static let dataPanelCornerRadius: CGFloat = 16
        static let dataPanelPadding: CGFloat = 16
        static let lineChartLineWidth = UI.Dimension(3, 4)
        
        static func dataPanelYOffset(_ displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return 20
            case .appeared:
                return 0
            case .dissolved:
                return 20
            }
        }
        static var searchBarHeight: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 36
                } else {
                    return 48
                }
            }
        }
    }
}
