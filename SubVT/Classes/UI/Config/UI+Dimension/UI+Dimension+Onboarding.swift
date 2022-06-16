//
//  UI+Dimension+Onboarding.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum Onboarding {
        static var pageNumberMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 46
                } else {
                    return 110
                }
            }
        }
        static let titleMarginTop: CGFloat = 52
        static var descriptionMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 18
                } else {
                    return 24
                }
            }
        }
        static var textHorizontalPadding: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 54
                } else {
                    return 100
                }
            }
        }
        static var navigationSectionMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 52
                } else {
                    return 93
                }
            }
        }
        static var navigationSectionMarginBottom: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return 50
                } else {
                    return 55
                }
            }
        }
        static let pageCircleSize: CGFloat = 6
        static let pageCircleSpacing: CGFloat = 15
    }
}
