//
//  Counter.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.07.2022.
//

import SwiftUI

struct Counter: AnimatableModifier {
    var format: String
    var value: CGFloat
    
    var animatableData: CGFloat {
        get { self.value }
        set { self.value = newValue }
    }
    
    func body(content: Content) -> some View {
        Text(String(format: format, Int(self.value)))
    }
}
