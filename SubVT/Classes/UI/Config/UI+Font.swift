//
//  UIConfig+Font.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

extension UI {
    enum Font {
        // general purpose
        static let actionButton = LexendDeca.semiBold.withSize(18)
        
        enum Introduction {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(24)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var subtitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
        }
        
        enum Onboarding {
            static var currentPage: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(14)
                } else {
                    return LexendDeca.semiBold.withSize(14)
                }
            }
            static var pageCount: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(14)
                }
            }
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(22)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var description: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
            static var skipButton: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(18)
                } else {
                    return LexendDeca.light.withSize(18)
                }
            }
            static var nextButton: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(18)
                } else {
                    return LexendDeca.semiBold.withSize(18)
                }
            }
        }
        
        enum NetworkSelection {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.semiBold.withSize(24)
                } else {
                    return LexendDeca.semiBold.withSize(36)
                }
            }
            static var subtitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.light.withSize(14)
                } else {
                    return LexendDeca.light.withSize(16)
                }
            }
            static var network: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    return LexendDeca.medium.withSize(14)
                } else {
                    return LexendDeca.medium.withSize(18)
                }
            }
        }
    }
}
