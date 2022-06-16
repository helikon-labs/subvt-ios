//
//  UI+Dimension+BgMorph.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.06.2022.
//

import SwiftUI

extension UI.Dimension {
    enum BgMorph {
        static let leftViewBlurRadius: CGFloat = 54
        static let middleViewBlurRadius: CGFloat = 84
        static let rightViewBlurRadius: CGFloat = 90
        
        static func yOffset(displayState: BasicViewDisplayState) -> CGFloat {
            switch displayState {
            case .notAppeared:
                return -500
            case .appeared:
                return -150
            case .dissolved:
                return -500
            }
        }
        
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
                        geometry.size.width * 2.72,
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
                if UIDevice.current.userInterfaceIdiom == .phone {
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
                } else {
                    switch step {
                    case .start:
                        return (
                            geometry.size.height * 0.19,
                            -geometry.size.height * 0.39
                        )
                    case .mid:
                        return (
                            geometry.size.width * 0.23,
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
        }
        
        static func leftViewRotation(
            colorScheme: ColorScheme,
            step: BgMorphView.Step
        ) -> Double {
            if colorScheme == .dark {
                switch step {
                case .start:
                    return 15
                case .mid:
                    return -5
                case .end:
                    return -5
                }
            } else {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    switch step {
                    case .start:
                        return 15
                    case .mid:
                        return 15
                    case .end:
                        return 15
                    }
                } else {
                    switch step {
                    case .start:
                        return 25
                    case .mid:
                        return 30
                    case .end:
                        return 25
                    }
                }
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
        
        static var rightViewRotation: Double {
            get {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return -13.16
                } else {
                    return 10
                }
            }
        }
    }
}
