//
//  Keyboard.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 5.12.2022.
//

import SwiftUI

struct KeyboardUtil {
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
