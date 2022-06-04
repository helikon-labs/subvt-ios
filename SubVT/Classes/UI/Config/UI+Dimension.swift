//
//  UIConfig+Dimension.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import UIKit

extension UI {
    enum Dimension {
        enum Onboarding {
            static var titleMarginTop: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 163
                    } else {
                        return 143
                    }
                }
            }
            static var subtitleMarginTop: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 24
                    } else {
                        return 18
                    }
                }
            }
            static var subtitleWidth: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 420
                    } else {
                        return 260
                    }
                }
            }
            static var getStartedButtonWidth: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 272
                    } else {
                        return 266
                    }
                }
            }
            static let getStartedButtonHeight: CGFloat = 64
            static var getStartedButtonMarginTop: CGFloat {
                get {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        return 40
                    } else {
                        return .infinity
                    }
                }
            }
            static var getStartedButtonMarginBottom: CGFloat {
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
}
