//
//  UIConfig+Image.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

extension UI {
    enum Image {
        enum Onboarding {
            static func get3DVolume(colorScheme: ColorScheme) -> SwiftUI.Image {
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
}
