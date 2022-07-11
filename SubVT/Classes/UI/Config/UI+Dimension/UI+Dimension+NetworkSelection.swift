//
//  UI+Dimension+NetworkSelection.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum NetworkSelection {
        static var titleMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 115
                } else {
                    return 195
                }
            }
        }
        static var subtitleMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 18
                } else {
                    return 24
                }
            }
        }
        
        static func topTextGroupOffset(displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return -50
            case .appeared:
                return 0
            case .dissolved:
                return 30
            }
        }
        
        static let networkGridMarginTop: CGFloat = 40
        static var networkButtonSize: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 128
                } else {
                    return 156
                }
            }
        }
        static let networkButtonPadding: CGFloat = 16
        static var networkButtonSpacing: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 8
                } else {
                    return 16
                }
            }
        }
        static var networkIconSize: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 40
                } else {
                    return 50
                }
            }
        }
        static let networkSelectionIndicatorSize: CGFloat = 7
        static var networkButtonShadowOffset: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 14
                } else {
                    return 18
                }
            }
        }
        
        static func networkButtonYOffset(displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return 20
            case .appeared:
                return 0
            case .dissolved:
                return 30
            }
        }
        
        static func snackbarYOffset<T>(fetchState: DataFetchState<T>) -> CGFloat {
            switch fetchState {
            case .idle:
                fallthrough
            case .loading:
                fallthrough
            case .success:
                return 92
            case .error:
                return -96
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
