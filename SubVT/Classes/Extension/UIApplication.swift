//
//  UIApplication.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 7.07.2022.
//

import SwiftUI

extension UIApplication {
    static var hasTopNotch: Bool {
        get {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.keyWindow?.safeAreaInsets.top ?? 0 > 0
        }
    }
    static var hasBottomNotch: Bool {
        get {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return windowScene?.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
    }
}
