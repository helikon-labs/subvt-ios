//
//  UIConfig+Font.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

extension UI {
    enum Font {
        enum Common {
            static let actionButton = LexendDeca.semiBold.withSize(14)
            static let title = LexendDeca.semiBold.withSize(15)
            static var dataPanelTitle = LexendDeca.light.withSize(10)
        }
        
        enum Onboarding {
            static let info = LexendDeca.regular.withSize(13)
        }
        
        enum Home {
            static let menuIcon = LexendDeca.regular.withSize(12)
            static let menuItem = LexendDeca.regular.withSize(14.5)
        }
        
        enum NetworkStatus {
            static let dataLarge: SwiftUI.Font = LexendDeca.semiBold.withSize(18)
        }
    }
}
