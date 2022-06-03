//
//  UIConfig.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 3.06.2022.
//

import SwiftUI
import UIKit

final class UIConfig {
    private init() {}
}

extension UIConfig {
    final class Dimension {
        private init() {}
        
        static var onboardingTitleMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 163
                } else {
                    return 143
                }
            }
        }
        static var onboardingSubtitleMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 24
                } else {
                    return 18
                }
            }
        }
        static var onboardingSubtitleWidth: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 420
                } else {
                    return 260
                }
            }
        }
        static var onboardingGetStartedButtonWidth: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 272
                } else {
                    return 266
                }
            }
        }
        static let onboardingGetStartedButtonHeight: CGFloat = 64
        static var onboardingGetStartedButtonMarginTop: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return 40
                } else {
                    return .infinity
                }
            }
        }
        static var onboardingGetStartedButtonMarginBottom: CGFloat {
            get {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return .infinity
                } else {
                    return 40
                }
            }
        }
    }
}

extension UIConfig {
    final class Font {
        private init() {}
        
        // general purpose
        static let actionButton = LexendDeca.semiBold.withSize(18)
        
        // onboarding
        static var onboardingTitle: SwiftUI.Font {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return LexendDeca.semiBold.withSize(36)
            } else {
                return LexendDeca.semiBold.withSize(24)
            }
        }
        static var onboardingSubtitle: SwiftUI.Font {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return LexendDeca.light.withSize(16)
            } else {
                return LexendDeca.light.withSize(14)
            }
        }
    }
}

extension UIConfig {
    final class Image {
        private init() {}
        
        static func getOnboarding3DVolume(colorScheme: ColorScheme) -> SwiftUI.Image {
            if colorScheme == .dark {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return SwiftUI.Image("3DLogoLargeDark")
                } else {
                    return SwiftUI.Image("3DLogoDark")
                }
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return SwiftUI.Image("3DLogoLargeLight")
                } else {
                    return SwiftUI.Image("3DLogoLight")
                }
            }
        }
    }
}

extension UIConfig {
    final class Color {
        private init() {}
        
        static let actionButtonBg = SwiftUI.Color(0x3b6eff)
        static let actionButtonText = SwiftUI.Color.white
    }
}
