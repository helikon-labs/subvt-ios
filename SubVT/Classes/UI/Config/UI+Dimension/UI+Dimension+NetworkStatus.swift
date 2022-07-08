//
//  UI+Dimension+NetworkStatus.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

extension UI.Dimension {
    enum NetworkStatus {
        static var titleMarginTop: CGFloat {
            get {
                if UIApplication.hasTopNotch {
                    return 70
                } else {
                    return 40
                }
            }
        }
        static var connectionStatusMarginLeft: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 4
                } else {
                    return 9
                }
            }
        }
        static var connectionStatusSize: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 7
                } else {
                    return 10
                }
            }
        }
        static let networkIconSize: CGFloat = 18
        static let networkSelectorPadding: CGFloat = 10
        static var validatorCountPanelHeight: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 128
                } else {
                    return 190
                }
            }
        }
        static var scrollContentMarginTop: CGFloat {
            get {
                return NetworkStatus.titleMarginTop + 68
            }
        }
        static var scrollContentMarginBottom: CGFloat {
            get {
                return UI.Dimension.TabBar.marginBottom
                + UI.Dimension.TabBar.height
            }
        }
    }
}
