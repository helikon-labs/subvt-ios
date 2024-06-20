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
            static let actionButton = LexendDeca.regular.withSize(14)
            static let title = LexendDeca.semiBold.withSize(15)
            static var dataPanelTitle = LexendDeca.light.withSize(10)
            static let dataMedium = LexendDeca.semiBold.withSize(12)
            static let info = LexendDeca.regular.withSize(13)
        }
        
        enum Home {
            static let menuIcon = LexendDeca.regular.withSize(12)
            static let menuItem = LexendDeca.regular.withSize(14.5)
        }
        
        enum NetworkStatus {
            static let dataSmall = LexendDeca.regular.withSize(10)
            static let dataLarge: SwiftUI.Font = LexendDeca.semiBold.withSize(18)
            static let dataXLarge: SwiftUI.Font = LexendDeca.semiBold.withSize(20)
            static let eraEpochTimestamp = LexendDeca.regular.withSize(10)
            static let network = LexendDeca.regular.withSize(11)
        }
        
        enum ValidatorSummary {
            static let display = LexendDeca.semiBold.withSize(12)
            static let balance = LexendDeca.light.withSize(10)
        }
    }
}
