//
//  PanelAppearance.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 13.07.2022.
//

import Foundation
import SwiftUI

struct PanelAppearance: ViewModifier {
    var displayState: BasicViewDisplayState
    var offset: UInt
    
    init(_ offset: UInt, _ displayState: BasicViewDisplayState) {
        self.offset = offset
        self.displayState = displayState
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: 0,
                y: UI.Dimension.Common.dataPanelYOffset(self.displayState)
            )
            .opacity(UI.Dimension.Common.displayStateOpacity(self.displayState))
            .animation(
                .easeInOut(duration: 0.2).delay(Double(offset) * 0.07),
                value: self.displayState
            )
    }
}
