//
//  UIConfig+Dimension.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import UIKit
import SwiftUI

extension UI {
    enum Dimension {
        enum Common {
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
        }
        
        enum BgMorph {
            static let leftViewBlurRadius: CGFloat = 54
            static let middleViewBlurRadius: CGFloat = 84
            static let rightViewBlurRadius: CGFloat = 90
            
            static func getLeftViewTransform(colorScheme: ColorScheme) -> CGAffineTransform {
                if colorScheme == .dark {
                    return CGAffineTransform.identity
                } else {
                    return CGAffineTransform.init(
                        a: 0.48,
                        b: 1.38,
                        c: -0.49,
                        d: 0.65,
                        tx: 0,
                        ty: 0
                    )
                }
            }
            
            static func getLeftViewSize(
                colorScheme: ColorScheme,
                geometry: GeometryProxy,
                step: BgMorphView.Step
            ) -> (CGFloat, CGFloat) {
                if colorScheme == .dark {
                    switch step {
                    case .start:
                        return (
                            geometry.size.width * 0.85,
                            geometry.size.height * 0.59
                        )
                    case .mid:
                        return (
                            geometry.size.width * 0.72,
                            geometry.size.height * 0.55
                        )
                    case .end:
                        return (
                            geometry.size.width * 0.97,
                            geometry.size.height * 0.62
                        )
                    }
                } else {
                    return (
                        geometry.size.width * 0.78,
                        geometry.size.height * 0.48
                    )
                }
            }
            
            static func getLeftViewOffset(
                colorScheme: ColorScheme,
                geometry: GeometryProxy,
                step: BgMorphView.Step
            ) -> (CGFloat, CGFloat) {
                if colorScheme == .dark {
                    switch step {
                    case .start:
                        return (
                            0,
                            -geometry.size.height * 0.15
                        )
                    case .mid:
                        return (
                            geometry.size.width * 0.07,
                            -geometry.size.height * 0.15
                        )
                    case .end:
                        return (
                            -geometry.size.width * 0.2,
                            -geometry.size.height * 0.09
                        )
                    }
                } else {
                    switch step {
                    case .start:
                        return (
                            geometry.size.height * 0.10,
                            -geometry.size.height * 0.39
                        )
                    case .mid:
                        return (
                            geometry.size.width * 0.13,
                            -geometry.size.height * 0.45
                        )
                    case .end:
                        return (
                            geometry.size.width * 0.1,
                            -geometry.size.height * 0.37
                        )
                    }
                }
            }
            
            static func getLeftViewRotation(step: BgMorphView.Step) -> Double {
                switch step {
                case .start:
                    return 15
                case .mid:
                    return -5
                case .end:
                    return -5
                }
            }
            
            static func getMiddleViewTransform(colorScheme: ColorScheme) -> CGAffineTransform {
                return CGAffineTransform.init(
                    a: 1,
                    b: 0.72,
                    c: -0.03,
                    d: 0.86,
                    tx: 0,
                    ty: 0
                )
            }
            
            static func getMiddleViewSize(
                geometry: GeometryProxy
            ) -> (CGFloat, CGFloat) {
                return (
                    geometry.size.width * 0.56,
                    geometry.size.height * 0.51
                )
            }
            
            static func getMiddleViewOffset(
                geometry: GeometryProxy,
                step: BgMorphView.Step
            ) -> (CGFloat, CGFloat) {
                switch step {
                case .start:
                    return (
                        geometry.size.width * 0.36,
                        -geometry.size.height * 0.18
                    )
                case .mid:
                    return (
                        geometry.size.width * 0.36,
                        -geometry.size.height * 0.18
                    )
                case .end:
                    return (
                        geometry.size.width * 0.49,
                        -geometry.size.height * 0.16
                    )
                }
            }
            
            static func getRightViewTransform(colorScheme: ColorScheme) -> CGAffineTransform {
                if colorScheme == .dark {
                    return CGAffineTransform.identity
                } else {
                    return CGAffineTransform.init(
                        a: 0.94,
                        b: 0.2,
                        c: 0.39,
                        d: 0.98,
                        tx: 0,
                        ty: 0
                    )
                }
            }
            
            static func getRightViewSize(
                geometry: GeometryProxy
            ) -> (CGFloat, CGFloat) {
                return (
                    geometry.size.width * 0.98,
                    geometry.size.height * 0.58
                )
            }
            
            static func getRightViewOffset(
                geometry: GeometryProxy,
                step: BgMorphView.Step
            ) -> (CGFloat, CGFloat) {
                switch step {
                case .start:
                    return (
                        geometry.size.width * 0.47,
                        -geometry.size.height * 0.21
                    )
                case .mid:
                    return (
                        geometry.size.width * 0.28,
                        -geometry.size.height * 0.21
                    )
                case .end:
                    return (
                        geometry.size.width * 0.49,
                        -geometry.size.height * 0.23
                    )
                }
            }
            
            static let rightViewRotation = -13.16
        }
        
        enum Introduction {
            static var titleMarginTop: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return 103
                    } else {
                        return 183
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
        }
        
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
            static var networkGridMarginTop: CGFloat = 40
            static var networkButtonSize: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return 128
                    } else {
                        return 156
                    }
                }
            }
            static var networkButtonCornerRadius: CGFloat = 12
            static var networkButtonPadding: CGFloat = 16
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
            static var networkSelectionIndicatorSize: CGFloat = 7
            static var networkButtonShadowOffset: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        return 11
                    } else {
                        return 17
                    }
                }
            }
        }
    }
}
