//
//  ItemListButtonStyle.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 16.10.2022.
//

import SwiftUI

struct ItemListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.none, value: configuration.isPressed)
    }
}
