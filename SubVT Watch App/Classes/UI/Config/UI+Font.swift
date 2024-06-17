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
        }
        
        enum Onboarding {
            static let info = LexendDeca.regular.withSize(13)
        }
        
        enum Snackbar {
            static let message = LexendDeca.light.withSize(15)
        }
        
        enum ActionFeedbackView {
            static let text = LexendDeca.semiBold.withSize(16)
        }
    }
}
