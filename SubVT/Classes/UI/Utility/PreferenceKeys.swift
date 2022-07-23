//
//  ViewOffsetKey.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 20.07.2022.
//

import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
