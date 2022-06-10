//
//  UIConfig+Color.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 4.06.2022.
//

import SwiftUI

extension UI {
    enum Color {
        enum Common {
            static let actionButton = SwiftUI.Color(0x3B6EFF)
            static let actionButtonPressed = SwiftUI.Color(0x1D54EF)
            static let actionButtonShadow = SwiftUI.Color(0x3B6EFF, alpha: 0.75)
            static let actionButtonText = SwiftUI.Color.white
        }
        
        enum BgMorph {
            static func getLeftViewOpacity(colorScheme: ColorScheme) ->  Double {
                (colorScheme == .dark) ? 1.0 : 0.55
            }
            
            static func getLeftViewColor(colorScheme: ColorScheme) -> SwiftUI.Color {
                if colorScheme == .dark {
                    return SwiftUI.Color(0x3B6EFF)
                } else {
                    return SwiftUI.Color(0x2AFB4D)
                }
            }
            
            static func getMiddleViewColor() -> SwiftUI.Color {
                return SwiftUI.Color(0xF5F5F5)
            }
            
            static func getRightViewOpacity(colorScheme: ColorScheme) ->  Double {
                (colorScheme == .dark) ? 1.0 : 0.46
            }
            
            static func getRightViewColor(colorScheme: ColorScheme) -> SwiftUI.Color {
                if colorScheme == .dark {
                    return SwiftUI.Color(0x2AFB4D)
                    
                } else {
                    return SwiftUI.Color(0x3B6EFF)
                }
            }
        }
    }
}
