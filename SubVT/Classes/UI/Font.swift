//
//  Font.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 2.06.2022.
//

import Foundation
import UIKit
import SwiftUI

enum LexendDeca: String {
    case black = "LexendDeca-Black"
    case bold = "LexendDeca-Bold"
    case extraBold = "LexendDeca-ExtraBold"
    case extraLight = "LexendDeca-ExtraLight"
    case light = "LexendDeca-Light"
    case medium = "LexendDeca-Medium"
    case regular = "LexendDeca-Regular"
    case semiBold = "LexendDeca-SemiBold"
    case thin = "LexendDeca-Thin"
    
    func withSize(_ size: CGFloat) -> Font {
        return Font.custom(self.rawValue, size: size)
    }
}
