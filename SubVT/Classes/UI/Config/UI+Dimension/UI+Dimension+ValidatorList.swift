//
//  UI+Dimension+ValidatorList.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 18.07.2022.
//

import SwiftUI

extension UI.Dimension {
    enum ValidatorList {
        static var titleMarginLeft: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 8
                } else {
                    return 24
                }
            }
        }
        static var searchBarMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 32
                } else {
                    return 40
                }
            }
        }
        static var scrollContentMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 168 + UI.Dimension.Common.topNotchHeight
                } else {
                    return 182 + UI.Dimension.Common.topNotchHeight
                }
            }
        }
        static var itemSpacing: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 8
                } else {
                    return 12
                }
            }
        }
    }
    
    enum ValidatorSummary {
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 18
        static let iconSpacing: CGFloat = 6
        static let balanceTopMargin: CGFloat = 12
    }
}
