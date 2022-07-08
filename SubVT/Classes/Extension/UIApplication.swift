//
//  UIApplication.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

extension UIApplication {
    static var hasBottomNotch: Bool {
        get {
            shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
    }
    static var hasTopNotch: Bool {
        get {
            shared.windows.first?.safeAreaInsets.top ?? 0 > 0
        }
    }
}
