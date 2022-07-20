//
//  UI+Dimension+TabBar.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 25.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum TabBar {
        static var height: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 66
                } else {
                    return 74
                }
            }
        }
        static let cornerRadius: CGFloat = 16
        static var itemWidth: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 75
                } else {
                    return 84
                }
            }
        }
        static var itemSpacing: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 10
                } else {
                    return 24
                }
            }
        }
        static var marginBottom: CGFloat {
            get {
                if UI.Dimension.Common.bottomNotchHeight > 0 {
                    return UI.Dimension.Common.bottomNotchHeight
                } else {
                    return UI.Dimension.Common.padding
                }
            }
        }
    }
}
