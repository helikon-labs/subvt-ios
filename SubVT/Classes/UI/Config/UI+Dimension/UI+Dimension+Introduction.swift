//
//  UI+Dimension+Introduction.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum Introduction {
        static func iconVolumeOffset(displayState: BasicViewDisplayState) -> (CGFloat, CGFloat) {
            switch displayState {
            case .notAppeared:
                return (-420, 420)
            case .appeared:
                return (-20, 20)
            case .dissolved:
                return (-420, 420)
            }
        }
        
        static func textYOffset(displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return -50
            case .appeared:
                return 0
            case .dissolved:
                return 50
            }
        }
        
        static var titleMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 115
                } else {
                    return 213
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
        
        static var subtitleWidth: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 260
                } else {
                    return 420
                }
            }
        }
        
        static func snackbarYOffset(isVisible: Bool) -> CGFloat {
            if isVisible {
                return -96
            } else {
                return 92
            }
        }
        
        static func snackbarOpacity(isVisible: Bool) -> CGFloat {
            if isVisible {
                return 1
            } else {
                return 0
            }
        }
    }
}
