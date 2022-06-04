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
        
        enum Onboarding {
            static var title: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return LexendDeca.semiBold.withSize(36)
                } else {
                    return LexendDeca.semiBold.withSize(24)
                }
            }
            static var subtitle: SwiftUI.Font {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    return LexendDeca.light.withSize(16)
                } else {
                    return LexendDeca.light.withSize(14)
                }
            }
        }
    }
}
