//
//  PressAction.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 22.07.2022.
//

import SwiftUI

struct PressAction: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}
